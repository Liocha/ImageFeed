import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagesPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesPresenter
        imagesPresenter.view = imagesListViewController
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(with: profilePresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",  // если подпись не нужна, оставьте пустую строку
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [
            imagesListViewController, profileViewController,
        ]
    }
}
