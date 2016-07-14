//
//  ClinicsViewModel.swift
//  Clinics
//
//  Created by Mark Sanvitale on 7/13/16.
//  Copyright © 2016 Mark Sanvitale. All rights reserved.
//

import Foundation

protocol ClinicsViewModelDelegate : class {
    func clinicsDidChange()
}

class ClinicsViewModel {
    weak var delegate: ClinicsViewModelDelegate?
    
    private var cachedClinics: [Clinic]? {
        didSet {
            // TODO bring the Keychain into the mix here? (via Locksmith CocoaPod)
            
            delegate?.clinicsDidChange()
            print("INFO - clinic view model now has \(cachedClinics?.count) clinics")
        }
    }
    
    var clinics: [Clinic] {
        if let clinics = cachedClinics {
            return clinics
        }
        // Cache is nil, so fetch via the service.
        ClinicService.sharedInstance.fetchClinicsWithCompletion() { [weak weakSelf = self] (clinicArray) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                // Do not update our clinic cache unless we received a non-nil response (otherwise, an
                // endless fetch loop is likely to occur, e.g. didSet on the cache would cause delegate
                // to call this function, triggering another fetch, etc.).
                if let clinics = clinicArray {
                    weakSelf?.cachedClinics = clinics
                }
            }
        }
        return [Clinic]()
    }
    
    func clinicPreferredDisplayText(clinic: Clinic) -> String {
        return clinic.preferred ?? false ? "Yes" : "No"
    }
    
    func clinicCityStateDisplayText(clinic: Clinic) -> String {
        if let city = clinic.location?.city, let state = clinic.location?.stateCode {
            return "\(city), \(state)"
        }
        return clinic.location?.city ?? clinic.location?.stateCode ?? ""
    }
    
    init() {
        print("DEBUG - init ClinicsViewModel")
    }
}
