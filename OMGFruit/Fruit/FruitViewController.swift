import UIKit

class FruitViewController: UIViewController {
    @IBOutlet weak var getFruitButton: UIButton?
    @IBOutlet weak var fruitImageView: UIImageView?
    @IBOutlet weak var fruitSummaryLabel: UILabel?

    var fruitService: FruitService?

    @IBAction func getFruit() {
        guard let fruitService = fruitService else { return }
        getFruitButton?.isEnabled = false

        fruitService.getFruit() { fruit, error in
            if let error = error {
                let alert = UIAlertController(title: "OMG NO", message: error.details, preferredStyle: .alert)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.getFruitButton?.isEnabled = true
                    self.fruitSummaryLabel?.text = fruit?.description
                    self.fruitImageView?.image = fruit?.image
                }
            }
        }
    }
}
