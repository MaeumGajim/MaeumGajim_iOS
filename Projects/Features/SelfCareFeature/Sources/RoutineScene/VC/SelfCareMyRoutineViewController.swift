import UIKit

import RxFlow
import RxCocoa
import RxSwift

import SnapKit
import Then

import Core
import Data
import DSKit

import Domain
import MGLogger
import MGNetworks

import SelfCareFeatureInterface

public class SelfCareMyRoutineViewController: BaseViewController<SelfCareMyRoutineViewModel>, Stepper, UIGestureRecognizerDelegate {

    private var naviBar = RoutineNavigationBarBar()

    private var myRoutineModel: SelfCareMyRoutineModel = SelfCareMyRoutineModel(
        titleTextData: SelfCareMyRoutineTextModel(
                titleText: "",
                infoText: ""
            ), myRoutineData: []
    )

    private var containerView = UIView()
    private var headerView = UIView()

    private let myRoutineTitleLabel = MGLabel(
        font: UIFont.Pretendard.titleLarge,
        textColor: .black,
        isCenter: false
    )

    private let myRoutineSubTitleLabel = MGLabel(
        font: UIFont.Pretendard.bodyMedium,
        textColor: DSKitAsset.Colors.gray600.color,
        isCenter: false,
        numberOfLineCount: 2
    )

    private var myRoutineTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.register(
            MyRoutineTableViewCell.self,
            forCellReuseIdentifier: MyRoutineTableViewCell.identifier
        )
    }

    private var plusRoutineButton = SelfCareButton(type: .plusRoutine)

    public override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationController?.isNavigationBarHidden = true
        self.view.frame = self.view.frame.inset(by: UIEdgeInsets(top: .zero, left: 0, bottom: .zero, right: 0))
    }

    public override func attribute() {
        super.attribute()

        view.backgroundColor = .white

        myRoutineTitleLabel.changeText(text: myRoutineModel.titleTextData.titleText)
        myRoutineSubTitleLabel.changeText(text: myRoutineModel.titleTextData.infoText)

        myRoutineTableView.delegate = self
        myRoutineTableView.dataSource = self

        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    public override func layout() {
        super.layout()

        view.addSubviews([naviBar, myRoutineTableView, plusRoutineButton, headerView])

        naviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 144.0))

        headerView.addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.bottom.equalToSuperview().inset(20.0)
        }

        containerView.addSubviews([myRoutineTitleLabel, myRoutineSubTitleLabel])

        myRoutineTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        myRoutineSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(myRoutineTitleLabel.snp.bottom).offset(12.0)
            $0.leading.equalToSuperview()
        }

        myRoutineTableView.tableHeaderView = headerView
        myRoutineTableView.snp.makeConstraints {
            $0.top.equalTo(naviBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        plusRoutineButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.bottom.equalToSuperview().inset(54.0)
            $0.height.equalTo(58.0)
        }
    }

    public override func bindActions() {
        plusRoutineButton.rx.tap
            .bind(onNext: { [weak self] in
                let useCase = DefaultSelfCareUseCase(repository: SelfCareRepository(networkService: DefaultSelfCareService()))

                let viewModel = SelfCareMyRoutineAddViewModel(useCase: useCase)
                let vc = SelfCareMyRoutineAddViewController(viewModel)
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
    }
    public override func bindViewModel() {
        let useCase = DefaultSelfCareUseCase(repository: SelfCareRepository(networkService: DefaultSelfCareService()))

        viewModel = SelfCareMyRoutineViewModel(useCase: useCase)

        let input = SelfCareMyRoutineViewModel.Input(
            getMyRoutineData: Observable.just(()).asDriver(onErrorDriveWith: .never()))

        let output = viewModel.transform(input, action: { output in
            output.myRoutineData
                .subscribe(onNext: { myRoutineData in
                    MGLogger.debug("myRoutineData: \(myRoutineData)")
                    self.myRoutineModel = myRoutineData
                }).disposed(by: disposeBag)
        })
    }
}

extension SelfCareMyRoutineViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == myRoutineModel.myRoutineData.count + 1 {
            return 100
        } else {
            return 94
        }
    }
}

extension SelfCareMyRoutineViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myRoutineModel.myRoutineData.count + 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == myRoutineModel.myRoutineData.count {
            let cell = UITableViewCell()
            cell.backgroundColor = .white
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MyRoutineTableViewCell.identifier,
                for: indexPath) as? MyRoutineTableViewCell
            let routine = myRoutineModel.myRoutineData[indexPath.row]
            cell?.setup(with: routine)
            cell?.selectionStyle = .none
            cell?.dotsButtonTap
                .bind(onNext: { [weak self] in
                    let modal = MGSelfCareRoutineBottomSheet(
                        editButtonTap: {},
                        storageButtonTap: {},
                        shareButtonTap: {},
                        deleteButtonTap: {})
                    let customDetents = UISheetPresentationController.Detent.custom(
                        identifier: .init("sheetHeight")
                    ) { _ in
                        return 257
                    }
                    
                    if let sheet = modal.sheetPresentationController {
                        sheet.detents = [customDetents]
                        sheet.prefersGrabberVisible = true
                    }
                    self?.present(modal, animated: true)
                }).disposed(by: disposeBag)
            
            return cell ?? UITableViewCell()
        }
    }
}

extension SelfCareMyRoutineViewController {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let useCase = DefaultSelfCareUseCase(repository: SelfCareRepository(networkService: DefaultSelfCareService()))

        let viewModel = SelfCareMyRoutineDetailViewModel(useCase: useCase)
        let vc = SelfCareMyRoutineDetailViewController(viewModel)
//        vc.routineID = myRoutineModel.myRoutineData[indexPath.row].
        navigationController?.pushViewController(vc, animated: true)
    }
}
