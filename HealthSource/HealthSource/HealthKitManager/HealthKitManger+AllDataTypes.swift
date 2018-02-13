//
//  HealthKitManger+AllDataTypes.swift
//  HealthSource
//
//  Created by Tamilarasu on 01/10/17.
//  Copyright © 2017 Tamilarasu. All rights reserved.
//

import Foundation
import HealthKit
extension HealthKtiManager{
    private func getAllReadQuantityTypeIdentifiers() -> [HKQuantityTypeIdentifier] {
        
        return [
            //            .bodyMassIndex,
            //            .bodyFatPercentage,
            //            .height,
            //            .bodyMass,
            //            .leanBodyMass,
            //            .waistCircumference,
            //Fitness
            .stepCount,
            //            .distanceWalkingRunning,
            //            .distanceCycling,
            //            .distanceWheelchair,
            //            .basalEnergyBurned,
            //            .activeEnergyBurned,
            //            .flightsClimbed,
            //            .nikeFuel,
//            .appleExerciseTime,
            //            .pushCount,
            //            .distanceSwimming,
            //            .swimmingStrokeCount,
            //            .vo2Max,
            .heartRate,
            //            .bodyTemperature,
            //            .basalBodyTemperature,
            //            .bloodPressureSystolic,
            //            .bloodPressureDiastolic,
            //            .respiratoryRate,
            //            .restingHeartRate,
            //            .walkingHeartRateAverage,
            //            .heartRateVariabilitySDNN,
            //            .oxygenSaturation,
            //            .peripheralPerfusionIndex,
            //            .bloodGlucose,
            //            .numberOfTimesFallen,
            //            .electrodermalActivity,
            //            .inhalerUsage,
            //            .insulinDelivery,
            //            .bloodAlcoholContent,
            //            .forcedVitalCapacity,
            //            .forcedExpiratoryVolume1,
            //            .peakExpiratoryFlowRate,
            //            .dietaryFatTotal,
            //            .dietaryFatPolyunsaturated,
            //            .dietaryFatMonounsaturated,
            //            .dietaryFatSaturated,
            //            .dietaryCholesterol,
            //            .dietarySodium,
            //            .dietaryCarbohydrates,
            //            .dietaryFiber,
            //            .dietarySugar,
            //            .dietaryEnergyConsumed,
            //            .dietaryProtein,
            //            .dietaryVitaminA,
            //            .dietaryVitaminB6,
            //            .dietaryVitaminB12,
            //            .dietaryVitaminC,
            //            .dietaryVitaminD,
            //            .dietaryVitaminE,
            //            .dietaryVitaminK,
            //            .dietaryCalcium,
            //            .dietaryIron,
            //            .dietaryThiamin,
            //            .dietaryRiboflavin,
            //            .dietaryNiacin,
            //            .dietaryFolate,
            //            .dietaryBiotin,
            //            .dietaryPantothenicAcid,
            //            .dietaryPhosphorus,
            //            .dietaryIodine,
            //            .dietaryMagnesium,
            //            .dietaryZinc,
            //            .dietarySelenium,
            //            .dietaryCopper,
            //            .dietaryManganese,
            //            .dietaryChromium,
            //            .dietaryMolybdenum,
            //            .dietaryChloride,
            //            .dietaryPotassium,
            //            .dietaryCaffeine,
            //            .dietaryWater,
            //            .uvExposure,
        ]
    }
    private func getAllWriteQuantityTypeIdentifiers() -> [HKQuantityTypeIdentifier] {
        var allWriteQuantityIdentifiers = getAllReadQuantityTypeIdentifiers()
        //        allWriteQuantityIdentifiers.remove(at: allWriteQuantityIdentifiers.index(of: HKQuantityTypeIdentifier.nikeFuel)!)
//        allWriteQuantityIdentifiers.remove(at: allWriteQuantityIdentifiers.index(of: HKQuantityTypeIdentifier.appleExerciseTime)!)
        //        allWriteQuantityIdentifiers.remove(at: allWriteQuantityIdentifiers.index(of: HKQuantityTypeIdentifier.appleExerciseTime)!)
        //        allWriteQuantityIdentifiers.remove(at: allWriteQuantityIdentifiers.index(of: HKQuantityTypeIdentifier.walkingHeartRateAverage)!)
        return allWriteQuantityIdentifiers
        
    }
    
    private func getAllReadCategoryIdentifiers()->[HKCategoryTypeIdentifier]{
        
        return [
            .sleepAnalysis,
            //            .appleStandHour,
            //            .cervicalMucusQuality,
            //            .ovulationTestResult,
            //            .menstrualFlow,
            //            .intermenstrualBleeding,
            //            .sexualActivity,
            //            .mindfulSession,
        ]
    }
    private func getAllWriteCategoryIdentifiers()->[HKCategoryTypeIdentifier]{
        
        var allWriteCategoryIdentifiers = getAllReadCategoryIdentifiers()
        //        allWriteCategoryIdentifiers.remove(at: allWriteCategoryIdentifiers.index(of: HKCategoryTypeIdentifier.appleStandHour)!)
        return allWriteCategoryIdentifiers
    }
    private func getAllReadCorrelationIdentifiers()->[HKCorrelationTypeIdentifier]{
        return [
            //            .bloodPressure,
            //            .food,
        ]
    }
    private func getAllWriteCorrelationIdentifiers()->[HKCorrelationTypeIdentifier]{
        let allWriteCorrelationIdentifiers = getAllReadCorrelationIdentifiers()
        return allWriteCorrelationIdentifiers
    }
    private func getDocumentTypeIdentifiers()->[HKDocumentTypeIdentifier]{
        return [
            //            .CDA
        ]
    }
    private func getWorkoutTypeIdentifier()->[String]{
        return [
            HKWorkoutTypeIdentifier
        ]
    }
    /*
     func getWorkoutRouteTypeIdentifier() -> [String]{
     return [HKWorkoutRouteTypeIdentifier]
     }
     */
    
    func getAllReadDataTypes() -> [HKObjectType] {
        var arrayofDataTypes = [HKObjectType]()
        for quantityIdentifier in getAllReadQuantityTypeIdentifiers() {
            arrayofDataTypes.append(HKObjectType.quantityType(forIdentifier: quantityIdentifier)!)
        }
        for categoryIdentifier in getAllReadCategoryIdentifiers() {
            arrayofDataTypes.append(HKObjectType.categoryType(forIdentifier: categoryIdentifier)!)
        }
        for correlatationIdentifier in getAllReadCorrelationIdentifiers(){
            arrayofDataTypes.append(HKObjectType.correlationType(forIdentifier: correlatationIdentifier)!)
        }
        for doumentTyeIdentifier in getDocumentTypeIdentifiers(){
            arrayofDataTypes.append(HKObjectType.documentType(forIdentifier: doumentTyeIdentifier)!)
        }
        arrayofDataTypes.append(HKObjectType.workoutType())
        
        return arrayofDataTypes
    }
    func getAllWriteDataTypes() -> [HKObjectType] {
        var arrayofDataTypes = [HKObjectType]()
        for quantityIdentifier in getAllWriteQuantityTypeIdentifiers() {
            arrayofDataTypes.append(HKObjectType.quantityType(forIdentifier: quantityIdentifier)!)
        }
        for categoryIdentifier in getAllWriteCategoryIdentifiers() {
            arrayofDataTypes.append(HKObjectType.categoryType(forIdentifier: categoryIdentifier)!)
        }
        for correlatationIdentifier in getAllWriteCorrelationIdentifiers(){
            arrayofDataTypes.append(HKObjectType.correlationType(forIdentifier: correlatationIdentifier)!)
        }
        for doumentTyeIdentifier in getDocumentTypeIdentifiers(){
            arrayofDataTypes.append(HKObjectType.documentType(forIdentifier: doumentTyeIdentifier)!)
        }
        arrayofDataTypes.append(HKObjectType.workoutType())
        
        return arrayofDataTypes
    }
    func getAllReadSmapleTypes() -> [HKObjectType] {
        var arrayofDataTypes = [HKObjectType]()
        for quantityIdentifier in getAllReadQuantityTypeIdentifiers() {
            arrayofDataTypes.append(HKObjectType.quantityType(forIdentifier: quantityIdentifier)!)
        }
        for categoryIdentifier in getAllReadCategoryIdentifiers() {
            arrayofDataTypes.append(HKObjectType.categoryType(forIdentifier: categoryIdentifier)!)
        }
        for correlatationIdentifier in getAllReadCorrelationIdentifiers(){
            arrayofDataTypes.append(HKObjectType.correlationType(forIdentifier: correlatationIdentifier)!)
        }
        for doumentTyeIdentifier in getDocumentTypeIdentifiers(){
            arrayofDataTypes.append(HKObjectType.documentType(forIdentifier: doumentTyeIdentifier)!)
        }
        arrayofDataTypes.append(HKObjectType.workoutType())
        
        return arrayofDataTypes
    }
}
