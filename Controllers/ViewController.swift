//
//  RoverViewController.swift
//  Mars-Rovers
//
//  Created by Shiv Kalola on 9/17/19.
//  Copyright © 2019 Shiv Kalola. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CalendarDelgate, UINavigationControllerDelegate {
    
    var calendarPicker: CalendarPicker?
    var currentDate = Date()
    var calendarArray: NSArray?
    var selectedDate: Int = 0
    var photoStore: PhotoStore!
    var photosToDisplay: [Photo] = []
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    var roverName = UserDefaults.standard.value(forKey: "rover") ?? "Curiosity"
    private let roverSectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    private let calendarSectionInsets = UIEdgeInsets(top: 0.0,
                                             left: 0.0,
                                             bottom: 0.0,
                                             right: 0.0)
    
    // Rover menu outlets
    @IBOutlet weak var selectRoverButton: UIButton!
    @IBOutlet var roverButtons: [UIButton]!
    
    // Calendar menu outlets
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    
    // Rover images outlet
    @IBOutlet weak var roverCollectionView: UICollectionView!
    
    // Rover menu actions
    @IBAction func roverSelection(_ sender: Any) {
        roverButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
                self.view.sendSubviewToBack(self.calendarCollectionView)
                self.view.sendSubviewToBack(self.roverCollectionView)
            })
        }
    }
    @IBAction func roverTapped(_ sender: UIButton) {
        selectRoverButton.titleLabel?.text = sender.titleLabel?.text
        UserDefaults.standard.set(sender.titleLabel!.text , forKey: "rover")
        selectedDateLabel.text = sender.titleLabel?.text
        roverButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
                self.view.sendSubviewToBack(self.calendarCollectionView)
                self.view.sendSubviewToBack(self.roverCollectionView)
                
                DispatchQueue.main.async {
                    self.roverCollectionView.reloadData()
                }
            })
        }
        print("this url: \(String(describing: NasaAPI.roverURL))")

    }
    
    func getCalendar() -> CalendarPicker {
        if calendarPicker == nil {
            calendarPicker = CalendarPicker()
            calendarPicker?.delegate = self
        }
        return calendarPicker!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.calendarArray = getCalendar().arrayOfDates()
        
        let indexPathForFirstRow = IndexPath(row: 0, section: 0)
        self.calendarCollectionView.selectItem(at: indexPathForFirstRow, animated: false, scrollPosition: [])
        self.collectionView(self.calendarCollectionView, didSelectItemAt: indexPathForFirstRow)
        
        selectRoverButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectRoverButton.titleLabel?.numberOfLines = 1
        selectRoverButton.titleLabel?.minimumScaleFactor = 0.25
        selectRoverButton.titleLabel?.textAlignment = NSTextAlignment.center

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the collection views, set the desired frames
        calendarCollectionView.delegate = self
        roverCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        roverCollectionView.dataSource = self
        self.view.addSubview(calendarCollectionView)
        self.view.addSubview(roverCollectionView)
        
        // Register cells
        calendarCollectionView.register(NasaCell.self, forCellWithReuseIdentifier: "NasaCell")
        roverCollectionView.register(CalendarViewCell.self, forCellWithReuseIdentifier: "CalendarViewCell")
        
        // Get images for cell
        photoStore = PhotoStore()
        photoStore.fetchNASAPhotos { (photosResult) in
            switch photosResult {
            case let .success(photos):
                self.photosToDisplay = photos
                print("these are the photos to display: \(self.photosToDisplay)")
            case let .failure(error):
                print("Error fetching nasa photos: \(error)")
            }
            self.roverCollectionView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if calendarCollectionView == scrollView {
            setSelectedItemFromScrollView(scrollView)
        }
    }
    
    func setSelectedItemFromScrollView(_ scrollView: UIScrollView) {
        if calendarCollectionView == scrollView {
            let center = CGPoint(x: scrollView.center.x + scrollView.contentOffset.x, y: scrollView.center.y + scrollView.contentOffset.y)
            let index = calendarCollectionView.indexPathForItem(at: center)
            if index != nil {
                calendarCollectionView.scrollToItem(at: index!, at: .centeredHorizontally, animated: true)
                self.calendarCollectionView.selectItem(at: index, animated: false, scrollPosition: [])
                self.collectionView(self.calendarCollectionView, didSelectItemAt: index!)
                
                self.selectedDate = (index?.row)!
                self.selectedDateLabel.text = self.calendarArray?[(index?.row)!] as? String
            }
            else {
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if calendarCollectionView == scrollView && !decelerate  {
            setSelectedItemFromScrollView(scrollView)
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.calendarCollectionView {
            return (calendarArray?.count)!
        }
        
        return self.photosToDisplay.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.roverCollectionView {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "NasaCell", for: indexPath) as! NasaCell
            
            let photo = photosToDisplay[indexPath.row]
            let data = try? Data(contentsOf: photo.img_src)
            if let imageData = data {
                let image = UIImage(data: imageData)
                cellB.updateImageView(with: image)
                let thumbnail = photo.img_src
                UserDefaults.standard.set(thumbnail, forKey: "thumbnail")
            }
            
            return cellB
            
        } else {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
            //1
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    return
                }
                // 2
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                    // 3
                    let imageUrl = UserDefaults.standard.url(forKey: "thumbnail")!
                    let imageData = try! Data(contentsOf: imageUrl)
                    let image = UIImage(data: imageData)
                    cellA.dateImage.image = image
                }
            }
            cellA.dateLabel.text = self.calendarArray?[indexPath.row] as? String
            
            return cellA
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.calendarCollectionView {
            self.selectedDate = indexPath.row
            let centeredIndexPath = IndexPath.init(item: selectedDate, section: 0)
            collectionView.scrollToItem(at: centeredIndexPath, at: .centeredHorizontally, animated: true)
            if indexPath == centeredIndexPath {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            self.selectedDateLabel.text = self.calendarArray?[indexPath.row] as! String?
        }
        else {
            let cell = collectionView.cellForItem(at: indexPath) as! NasaCell
            
            func imageTapped(image:UIImage){
                // Enlarge image on tap
                let newImageView = UIImageView(image: image)
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                UIView.transition(with: self.view, duration: 1.0, options: [.transitionCrossDissolve], animations: {
                    self.view.addSubview(newImageView)
                }, completion: nil)
                
                // Add label with image metadata on tap
                label.center = CGPoint(x: 200, y: 700)
                label.numberOfLines = 3;
                label.textColor = UIColor.white
                label.textAlignment = .left
                label.font = label.font.withSize(20)
                label.text = "\(photosToDisplay[indexPath.row].earth_date) \nNavigation Camera \n\(roverName)"
                self.view.addSubview(label)
            }
 
            imageTapped(image: cell.imageView.image!)
        }
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.transition(with: self.view, duration: 1.0, options: [.transitionCrossDissolve], animations: {
            sender.view?.removeFromSuperview()
            self.label.removeFromSuperview()
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
        cell.dateLabel?.textColor = UIColor.black
    }
 
}

extension ViewController : UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            if collectionView == self.calendarCollectionView {
                return CGSize(width: 60.0, height: 65.0)
            }
            
            let paddingSpace = roverSectionInsets.left * 3
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / 3
            
            return CGSize(width: widthPerItem, height: widthPerItem)

        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
             if collectionView == self.calendarCollectionView {
                return calendarSectionInsets
            }
            
            return roverSectionInsets
            
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            if collectionView == self.calendarCollectionView{
                return calendarSectionInsets.top
            }
            
            return roverSectionInsets.left
        }

}
