import UIKit

import SnapKit
import Then

import Core
import DSKit
import SelfCareFeatureInterface

public class SelfCareMyRoutineEditViewController: BaseViewController<SelfCareMyRoutineEditViewModel> {
    
    private var myRoutineEditModel = MyRoutineEditModel.routineData
    
    private var headerView = UIView()
    
    private var titleTextView = MGTitleTextView(type: .title)
    
    private var myRoutineDetailTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.register(MyRoutineEditTableViewCell.self,
                    forCellReuseIdentifier: MyRoutineEditTableViewCell.identifier)
    }
    
    
    private let underLine = MGLine(lineHeight: 1.0)
    private let underBackView = UIView()
    private let buttonSpaceView = UIView()
    
    private var plusPostureButton = SelfCareButton(type: .posturePlus)
    private var editButton = SelfCareButton(type: .edit)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    public override func attribute() {
        super.attribute()
        
        myRoutineDetailTableView.delegate = self
        myRoutineDetailTableView.dataSource = self
    }
    
    public override func layout() {
        super.layout()
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 132.0))
        view.addSubviews([myRoutineDetailTableView, underBackView])
        
        headerView.addSubview(titleTextView)
        
        titleTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.bottom.equalToSuperview().inset(32.0)
        }
        
        myRoutineDetailTableView.tableHeaderView = headerView
        myRoutineDetailTableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(105.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(695.0)
        }
        
        underBackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(myRoutineDetailTableView.snp.bottom)
        }
        
        underBackView.addSubviews([underLine, buttonSpaceView,  plusPostureButton, editButton])
        
        underLine.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        buttonSpaceView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(8.0)
            $0.centerX.equalToSuperview()
        }
        
        plusPostureButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(20.0)
            $0.leading.equalToSuperview().offset(20.0)
            $0.trailing.equalTo(buttonSpaceView.snp.leading)
        }
        
        editButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(20.0)
            $0.trailing.equalToSuperview().offset(-20.0)
            $0.leading.equalTo(buttonSpaceView.snp.trailing)
        }
    }
}
extension SelfCareMyRoutineEditViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 216
    }
}
extension SelfCareMyRoutineEditViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myRoutineEditModel.data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MyRoutineEditTableViewCell.identifier,
            for: indexPath) as? MyRoutineEditTableViewCell
        let editData = myRoutineEditModel.data[indexPath.row]
        cell?.setup(image: editData.image, name: editData.name)
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
}
