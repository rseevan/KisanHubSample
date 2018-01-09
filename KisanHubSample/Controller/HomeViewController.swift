//
//  HomeViewController.swift
//  KisanHubSample
//
//  Created by Seevan Ranka on 04/01/18.
//  Copyright © 2018 Seevan Ranka. All rights reserved.
//

import UIKit
import MessageUI
import Toast_Swift

class HomeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var emailTxtFld: UITextField!
    
    var csvText = "region_code,weather_param,year, key, value\n"
    let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
    var fileUrls = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downloadFilesBtnClicked(_ sender: Any) {
        ToastManager.shared.style = ToastStyle()
        self.view.makeToastActivity(.center)
        let urlList = ["https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmax/date/UK.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmin/date/UK.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmean/date/UK.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Sunshine/date/UK.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Rainfall/date/UK.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmax/date/England.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmin/date/England.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmean/date/England.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Sunshine/date/England.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Rainfall/date/England.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmax/date/Wales.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmin/date/Wales.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmean/date/Wales.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Sunshine/date/Wales.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Rainfall/date/Wales.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmax/date/Scotland.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmin/date/Scotland.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmean/date/Scotland.txt", "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Sunshine/date/Scotland.txt","https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Rainfall/date/Scotland.txt"]
        var count = 0
        for url in urlList {
            let urlSeg = url.components(separatedBy: "/")
            let fileName = urlSeg.suffix(3).joined(separator: "")
            let destinationFileUrl = documentsUrl.appendingPathComponent(fileName)
            if let URL = NSURL(string: url) {
                Downloader.load(url: URL as URL, to: destinationFileUrl, completion: { (tempUrl) in
                    count += 1
                    self.fileUrls.append(tempUrl)
                    if count == urlList.count-1 {
                        self.view.hideToastActivity()
                    }
                    print("Downloaded successfully")
                    
                })
            }
        }
    }
    
    @IBAction func exportCSVClicked(_ sender: Any) {
        if emailTxtFld.text != "" {
            if isValidEmail(testStr: emailTxtFld!.text!)
            {
            } else {
                let alert = UIAlertController(title: "", message: "Invalid email.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
                });
                alert.addAction(action)
                self.present(alert, animated: true, completion:nil)
                return
            }
            if fileUrls.count == 0 {
                let alert = UIAlertController(title: "", message: "Please download the files first to create the csv", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
                });
                alert.addAction(action)
                self.present(alert, animated: true, completion:nil)
                return
            } else {
            for url in fileUrls {
                do {
                    // Read the file contents
                    let data = try String(contentsOf: url)
                    let rawArray = data.components(separatedBy: .newlines)
                    var dataArray = [String]()
                    for raw in rawArray {
                        if raw.count != 0 {
                            dataArray.append(raw)
                        }
                    }
                    convertToCSVFormat(dataStrings: dataArray)
                } catch let error as NSError {
                    print("Failed reading from URL: \(url), Error: " + error.localizedDescription)
                }
            }
                writeCSV()

            }
        } else {
            let alert = UIAlertController(title: "Try Again", message: "Invalid Email.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
                
            });
            alert.addAction(action)
            self.present(alert, animated: true, completion:nil)
            return
        }
    }
    
    func convertToCSVFormat(dataStrings: [String] )
    {
        let zerothArray = dataStrings[0]
        let headerArray = zerothArray.components(separatedBy: .whitespaces)
        let firstTag = headerArray[0]
        let secongTag = headerArray.dropFirst().joined(separator: " ")
        let seventhLineArray = dataStrings[6].components(separatedBy: .whitespaces)
        let monthsArray = removeEmptySpacesFromArrayAndDropFirst(data: seventhLineArray)
        let dataArray = dataStrings.dropFirst(7)
        for data in dataArray {
            let dataPoints = data.components(separatedBy: .whitespaces)
            let year = dataPoints[0]
            let valuePoints =  removeEmptySpacesFromArrayAndDropFirst(data: dataPoints)
            for i in 0..<monthsArray.count {
                var tempString = ""
                if valuePoints[i] == "---" {
                    tempString = "\(firstTag), \(secongTag), \(year), \(monthsArray[i]), N/A\n"
                } else {
                    tempString = "\(firstTag), \(secongTag), \(year), \(monthsArray[i]), \(valuePoints[i])\n"
                }
                csvText.append(tempString)
            }
        }
    }
    
    func writeCSV()
    {
        let destinationFileUrl = documentsUrl.appendingPathComponent("Statistics.csv")
        do {
            try csvText.write(to: destinationFileUrl, atomically: true, encoding: String.Encoding.utf8)
            
            sendEmail(emailId: emailTxtFld.text!)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    func removeEmptySpacesFromArrayAndDropFirst(data: [String]) -> [String]{
        var resultArray = [String]()
        let sampleArray = data.dropFirst()
        for sample in sampleArray {
            if sample.count != 0 {
                resultArray.append(sample)
            }
        }
        return resultArray
    }
    
    func sendEmail(emailId: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([emailId])
            mail.setMessageBody("Download the attached file.", isHTML: true)
            mail.setSubject("Statistics.csv")
            let data = csvText.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            mail.addAttachmentData(data!, mimeType: "text/csv", fileName: "Statistics.csv")
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "Can't send email", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            });
            alert.addAction(action)
            self.present(alert, animated: true, completion:nil)        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        switch result {
        case .sent:
            let alert = UIAlertController(title: "", message: "Email Sent.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            });
            alert.addAction(action)
            self.present(alert, animated: true, completion:nil)
            break
        default:
            break
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

