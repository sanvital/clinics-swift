//
//  ClinicTypes.swift
//  Clinics
//
//  Created by Mark Sanvitale on 7/12/16.
//  Copyright © 2016 Mark Sanvitale. All rights reserved.
//

import Foundation

struct GeoLocation {
    enum JsonKey: String {
        case Longitude = "longitude"
        case Latitude = "latitude"
    }
    
    let longitude: Double
    let latitude: Double
    
    init?(jsonDict: [String : AnyObject]) {
        if let lonJson = jsonDict[GeoLocation.JsonKey.Longitude.rawValue],
            let lon = lonJson as? Double,
            let latJson = jsonDict[GeoLocation.JsonKey.Latitude.rawValue],
            let lat = latJson as? Double {
                longitude = lon
                latitude = lat
        } else {
            return nil
        }
    }
}

struct Location {
    enum JsonKey: String {
        case City = "city"
        case GeoLocation = "geoLocation"
        case PostalCode = "postalCode"
        case StateCode = "stateCode"
        case StreetName = "streetName"
    }
    
    // All properties are individually designated as optional, however, the initializer forces either
    // (city AND state) OR postalCode to be non-nil (else init fails).
    let streetName: String?
    let city: String?
    let stateCode: String?
    let postalCode: String?
    let geoLocation: GeoLocation?
    
    init?(jsonDict: [String : AnyObject]) {
        streetName = jsonDict[Location.JsonKey.StreetName.rawValue] as? String
        city = jsonDict[Location.JsonKey.City.rawValue] as? String
        stateCode = jsonDict[Location.JsonKey.StateCode.rawValue] as? String
        postalCode = jsonDict[Location.JsonKey.PostalCode.rawValue] as? String
        
        if let geoValue = jsonDict[Location.JsonKey.GeoLocation.rawValue],
            let geoDict = geoValue as? [String : AnyObject] {
                geoLocation = GeoLocation(jsonDict: geoDict)
        } else {
            geoLocation = nil
        }
        
        // Enforce minimal location data.
        if postalCode == nil && (city == nil || stateCode == nil) {
            return nil
        }
    }
}

struct Clinic {
    enum JsonKey: String {
        case Id = "id"
        case Location = "location"
        case Name = "name"
        case ProviderId = "providerId"
        case Preferred = "preferred"
    }
    
    // An identity (both an identifier and a name) is the only required property.
    let identity: (id: String, name: String)
    let preferred: Bool?
    let location: Location?
    
    init?(jsonDict: [String : AnyObject]) {
        if let jsonId = jsonDict[Clinic.JsonKey.Id.rawValue] ?? jsonDict[Clinic.JsonKey.ProviderId.rawValue],
            let identifier = jsonId as? String,
            let jsonName = jsonDict[Clinic.JsonKey.Name.rawValue],
            let name = jsonName as? String {
                identity = (identifier, name)
        } else {
            // Without a fully-populated identity, initialization fails.
            return nil
        }
        
        preferred = jsonDict[Clinic.JsonKey.Preferred.rawValue] as? Bool
        if let locationValue = jsonDict[Clinic.JsonKey.Location.rawValue],
            let locationDict = locationValue as? [String : AnyObject] {
                location = Location(jsonDict: locationDict)
        } else {
            location = nil
        }
    }
}
