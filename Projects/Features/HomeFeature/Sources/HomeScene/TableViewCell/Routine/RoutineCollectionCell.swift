import UIKit

import RxSwift
import RxCocoa

import Then
import SnapKit

import Core
import DSKit

import Domain

import HomeFeatureInterface

public class RoutineCollectionCell: UICollectionViewCell, CollectoionCellID {

    public static var identifier: String = "RoutineCollectionCell"

    private var routineImageView = UIImageView().then {
        $0.backgroundColor = DSKitAsset.Colors.gray100.color
        $0.layer.cornerRadius = 24.0
    }

    private var nameLabel = MGLabel(
        textColor: .black,
        isCenter: true
    )

    private var setsLabel = MGLabel(
        textColor: .darkGray,
        isCenter: true
    )

    private var repsLabel = MGLabel(
        textColor: .darkGray,
        isCenter: true
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews([routineImageView,
                     nameLabel,
                     setsLabel,
                     repsLabel])

        routineImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16.0)
            $0.height.width.equalTo(48.0)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(routineImageView.snp.trailing).offset(10.0)
            $0.top.equalTo(routineImageView.snp.top)
        }

        setsLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(nameLabel.snp.leading)
        }

        repsLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(setsLabel.snp.trailing)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with routine: RoutineModel) {
        nameLabel.text = routine.exercise
        setsLabel.text = "세트: \(routine.sets)"
        repsLabel.text = "횟수: \(routine.reps)"
    }
}
