//
//  ClinicService.swift
//  Clinics
//
//  Created by Mark Sanvitale on 7/12/16.
//  Copyright © 2016 Mark Sanvitale. All rights reserved.
//

import Foundation

class ClinicService {
    // Singleton pattern, via stored type property, which is all we need given that (language reference) 
    // "Stored type properties are lazily initialized on their first access. They are guaranteed to be 
    // initialized only once, even when accessed by multiple threads simultaneously, and they do not need 
    // to be marked with the lazy modifier".
    static let sharedInstance = ClinicService()
    
    typealias ClinicsReadyClosureType = ([Clinic]?) -> Void
    
    func fetchClinicsWithCompletion(clinicsReady: ClinicsReadyClosureType) {
        print("INFO - fetching clinic list")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak weakSelf = self] () -> Void in
            let serviceResponse = weakSelf?.clinics
            clinicsReady(serviceResponse)
        }
    }
    
    private var clinics: [Clinic]? {
        var result: [Clinic]?
        if let clinicDictArray = self.simulatedServerResponse as? [[String : AnyObject]] {
            result = [Clinic]()
            for clinicJsonDict in clinicDictArray {
                if let clinic = Clinic(jsonDict: clinicJsonDict) {
                    result?.append(clinic)
                }
            }
        }
        return result
    }
    
    private var simulatedServerResponse: [AnyObject]? {
        var result: [AnyObject]?
        if let clinicListURL = NSBundle.mainBundle().URLForResource("clinicList", withExtension: "json"),
            let clinicListData = NSData(contentsOfURL: clinicListURL) {
                // The expected file was located within our application bundle, and the data from this
                // location was read.
                var clinicListJSON: AnyObject?
                var conversionError: NSError?
                do {
                    // "If an error occurs during the parse, then the error parameter will be set and the result will be nil."
                    clinicListJSON = try NSJSONSerialization.JSONObjectWithData(clinicListData, options: NSJSONReadingOptions.MutableContainers)
                } catch let error as NSError {
                    conversionError = error
                } catch {
                    // Catch-all to prevent the error from propagating.
                }
                
                if clinicListJSON != nil {
                    // The JSON data is expected to be an array that contains a single dictionary. This 
                    // dictionary includes an array whose contents are more attractive from the perspective 
                    // of being a data-source for clinics. For this coding exercise, let's grab this resource.
                    //
                    if let clinicalTypeArray = clinicListJSON as? [[String : AnyObject]] {
                        // We have the expected root JSON object.
                        //
                        if let clinicTypeDictionary = clinicalTypeArray.first,
                            let recommendedClinicArray = clinicTypeDictionary["recommendations"] as? [AnyObject] {
                            result = recommendedClinicArray
                        } else {
                            // Set the result array to be a valid/non-nil object (specifically, an empty array)
                            // since the lack of clinics was not caused by any unexpected errors.
                            result = [AnyObject]()
                        }
                    } else {
                        print("ERROR - unexpected organization of clinicList data")
                    }
                } else {
                    print("ERROR - failed to parse clinicList.json bundle resource: [descrip]\(conversionError?.localizedDescription) [code]\(conversionError?.code)")
                }
        } else {
            print("ERROR - failed to locate or read clinicList.json bundle resource")
        }
        
        return result
    }
    
    // restrict init to prevent additional instances of this class, i.e. the singleton for all.
    private init() {}
}
