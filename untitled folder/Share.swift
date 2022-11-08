//
//  Share.swift
//  Newmi
//
//  Created by Demetris Georgiou on 08/11/2022.
//

import Foundation
import TabularData
import CoreXLSX


@objc func openDocument() {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.spreadsheet], asCopy: true)//"com.microsoft.excel.xls"
    documentPicker.delegate = self
    documentPicker.allowsMultipleSelection = false
    documentPicker.shouldShowFileExtensions = true
    present(documentPicker, animated: true, completion: nil)
}

func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    
}

func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else { return }
    
    var newURL = FileManager.getDocumentsDirectory()
    newURL.appendPathComponent(url.lastPathComponent)
    
    do {
        if FileManager.default.fileExists(atPath: newURL.path) {
            try FileManager.default.removeItem(atPath: newURL.path)
        }
        try FileManager.default.moveItem(atPath: url.path, toPath: newURL.path)
        //            print("The new URL: \(newURL)")
        
        if let filename = urls.first?.lastPathComponent {
            //                self.pickedFile.append(filename)
            //                print(filename)
            makeFile(path: newURL, docName: filename)
        }
        
        
    } catch {
        print(error.localizedDescription)
    }
    //        printAll()
}

func printAll(){
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        // process files
        //            print(fileURLs)
        makeFile(path: fileURLs[0], docName: "")
    } catch {
        print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
    }
}

func makeFile(path:URL, docName:String){
    do{
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let localUrl = documentDirectory!.appendingPathComponent(docName)//"Nicosia.xlsx")
        
        if FileManager.default.fileExists(atPath: localUrl.path){
            if let fil = NSData(contentsOfFile: localUrl.path) {
                var arr:[City] = []
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.timeZone = TimeZone(abbreviation: "EET")
                
                
                
                let file = try XLSXFile(data: fil as Data)
                for wbk in try! file.parseWorkbooks() {
                    for (_, path) in try! file.parseWorksheetPathsAndNames(workbook: wbk) {
                        
                        let worksheet = try! file.parseWorksheet(at: path)
                        for row in worksheet.data?.rows ?? [] {
                            //                                print(row)
                            var date:String?
                            var name:String?
                            var surname:String?
                            var address:String?
                            var addressInfo:String?
                            var area:String?
                            var pharmacyPhoneNo:String?
                            var homePhoneNo:String?
                            for c in row.cells {
                                //                                    print(c)
                                if c.reference.column.value == "A"{
                                    
                                    if let dateVal = c.dateValue{
//                                            if dateVal < Date(){
//                                                continue
//                                            }
//                                            print(dateVal)
                                        let date2 = Calendar.current.date(bySettingHour: 21, minute: 00, second: 00, of: dateVal)
                                        date = dateFormatter.string(from:date2!)// dateVal)
                                        
                                    }else{
                                        date = nil
                                    }
                                }
                                if c.reference.column.value == "D"{
                                    name = c.value
                                    
                                }
                                if c.reference.column.value == "E"{
                                    surname = c.value
                                }
                                if c.reference.column.value == "F"{
                                    address = c.value
                                }
                                if c.reference.column.value == "G"{
                                    addressInfo = c.value
                                }
                                if c.reference.column.value == "H"{
                                    area = c.value
                                }
                                if c.reference.column.value == "I"{
                                    pharmacyPhoneNo = c.value
                                }
                                if c.reference.column.value == "J"{
                                    homePhoneNo = c.value
                                }
                                
                                
                            }
                            var obj:City!
                            
                            if date != nil{
                                obj = City.init(date: date, name: name, surname: surname, address: address, addressInfo: addressInfo, area: area, pharmacyPhoneNo: pharmacyPhoneNo, homePhoneNo: homePhoneNo)
                                arr.append(obj)
                            }
                        }
                    }
                    //                        let dog = Dog(name: "Rex", owner: "Etgar")
                    
                    //                        var arr1 = ["nicosia":arr]
                    let pha = Pharmacies.init(city: arr)
                    //                        print("arr =",arr)
                    //                        let ph = Pharmacies(city: arr)
                    
                    //                        let ph = Pharmacies.init(cities: <#T##[DataClass]#>)
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = .prettyPrinted
                    let jsonData = try jsonEncoder.encode(pha)
                    let json = String(data: jsonData, encoding: String.Encoding.utf8)
                    
                    //                        print(json)
                    //                        let jsonDat:JSON = JSON(json!)
                    //                        print("jsonDat", jsonDat)
                    //                        print(json!)
                    
                    let alert = UIAlertController(title: "Upload?", message: "Upload new file to Firebase?", preferredStyle: .alert)
                    let actionNic = UIAlertAction(title: "Nicosia", style: .default) { action in
                        self.startUploading(json: json!, city: action.title!)
                    }
                    let actionLim = UIAlertAction(title: "Limassol", style: .default) { action in
                        self.startUploading(json: json!, city: action.title!)

                    }
                    let actionLarn = UIAlertAction(title: "Larnaca", style: .default) { action in
                        self.startUploading(json: json!, city: action.title!)

                    }
                    let actionPaphos = UIAlertAction(title: "Paphos", style: .default) { action in
                        self.startUploading(json: json!, city: action.title!)

                    }
                    let actionAmm = UIAlertAction(title: "Ammochostos", style: .default) { action in
                        self.startUploading(json: json!, city: action.title!)

                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                        
                    }
                    
                    alert.addAction(actionNic)
                    alert.addAction(actionLim)
                    alert.addAction(actionLarn)
                    alert.addAction(actionPaphos)
                    alert.addAction(actionAmm)
                    alert.addAction(cancel)
                    
                    self.present(alert, animated: true)
                    
                    makeTableView(pharmacies: pha)
                    
                    
                }
            }}
    }catch{
        print(error.localizedDescription)
    }
}
