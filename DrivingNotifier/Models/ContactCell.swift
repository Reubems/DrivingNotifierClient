import Foundation
import UIKit

protocol ContactCellDelegate: class {
    func deleteContact(email: String)
}

class ContactCell: UITableViewCell {
    let name = UILabel()
    let email = UILabel()
    let deleteButton = UIButton()
    weak var handler: ContactCellDelegate?

    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let image = UIImage(named: "minus")
        let tinted = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        deleteButton.setImage(tinted, for: UIControlState.normal)
        deleteButton.tintColor = UIColor.red

        contentView.addSubview(name)
        contentView.addSubview(email)
        contentView.addSubview(deleteButton)

        name.adjustsFontSizeToFitWidth = true
        email.adjustsFontSizeToFitWidth = true
        email.textColor = Color.softDarkness.value

        name.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.equalTo(200)
        }

        email.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(contentView.bounds.width * 0.2)
            make.width.equalToSuperview().multipliedBy(0.6)
        }

        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.right.equalToSuperview().offset(-30)
        }

        deleteButton.addTarget(self, action: #selector(onDeleteButtonTap), for: .touchDown)

    }

    @objc func onDeleteButtonTap() {
        guard let email = email.text else { return }
        handler?.deleteContact(email: email)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
