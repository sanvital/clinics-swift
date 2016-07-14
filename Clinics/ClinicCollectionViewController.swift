//
//  ClinicCollectionViewController.swift
//  Clinics
//
//  Created by Mark Sanvitale on 7/12/16.
//  Copyright © 2016 Mark Sanvitale. All rights reserved.
//

import UIKit
import MapKit

class ClinicCollectionViewController: UICollectionViewController {

    lazy var clinicsModel = ClinicsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = title
        clinicsModel.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowClinicDetail" {
            if let detailVC = segue.destinationViewController as? ClinicDetailViewController,
                let clinicIndex = collectionView?.indexPathsForSelectedItems()?.first?.row where clinicIndex < clinicsModel.clinics.count {
                    detailVC.clinic = clinicsModel.clinics[clinicIndex]
                    detailVC.clinicsModel = clinicsModel
            }
        }
    }
    
    //
    // UICollectionViewDataSource
    //
    private let reuseIdentifier = "ClinicListCell"
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clinicsModel.clinics.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if let clinicCell = cell as? ClinicListCell {
            let clinic = clinicsModel.clinics[indexPath.row]
            clinicCell.nameLabel.text = clinic.identity.name
            clinicCell.preferredLabel.text = clinicsModel.clinicPreferredDisplayText(clinic)
        }
        return cell
    }
}

extension ClinicCollectionViewController : ClinicsViewModelDelegate {
    func clinicsDidChange() {
        collectionView?.reloadData()
    }
}

//
// Ancillary clinic views and view controllers
//

class ClinicListCell : UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var preferredLabel: UILabel!
}

class ClinicDetailViewController : UIViewController {
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var zipcodeLabel: UILabel!
    
    var clinic: Clinic?
    var clinicsModel: ClinicsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = clinic?.identity.name
        
        streetLabel.text = clinic?.location?.streetName ?? ""
        if let clinic = clinic {
            cityStateLabel.text = clinicsModel?.clinicCityStateDisplayText(clinic)
        }
        zipcodeLabel.text = clinic?.location?.postalCode
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowClinicMap" {
            if let mapView = segue.destinationViewController.view as? MKMapView,
                let geoloc = clinic?.location?.geoLocation {
                    let locationCoord = CLLocationCoordinate2D(latitude: geoloc.latitude, longitude: geoloc.longitude)
                    let region = MKCoordinateRegion(center: locationCoord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
                    mapView.setRegion(region, animated: true)
            }
        }
    }
}
