import Foundation
import UIKit

class ContactDrivingCell: UITableViewCell {
    let name = UILabel()
    let email = UILabel()

    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(name)
        contentView.addSubview(email)

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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
