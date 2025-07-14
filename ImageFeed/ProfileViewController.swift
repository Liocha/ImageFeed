import UIKit

class ProfileViewController: UIViewController {
    private var nameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var helloWorldLabel: UILabel!
    private var profileImageView: UIImageView!
    private var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupHelloWorldLabel()
        setupActionButton()
    }
    
    private func setupProfileImage() {
        profileImageView = UIImageView(image: UIImage(named: "profileImage"))
        profileImageView.tintColor = .gray
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .primaryText
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupUsernameLabel() {
        usernameLabel = UILabel()
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.textColor = .primaryText
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupHelloWorldLabel() {
        helloWorldLabel = UILabel()
        helloWorldLabel.text = "Hello, world!"
        helloWorldLabel.textColor = .primaryText
        
        helloWorldLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        helloWorldLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(helloWorldLabel)
        
        NSLayoutConstraint.activate([
            helloWorldLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            helloWorldLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupActionButton() {
        actionButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(didTapButton)
        )
        actionButton.tintColor = .red
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            actionButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    @objc private func didTapButton() {
        // Обработка нажатия кнопки
    }
}
