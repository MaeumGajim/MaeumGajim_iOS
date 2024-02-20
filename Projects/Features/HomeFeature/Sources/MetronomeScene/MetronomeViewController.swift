import UIKit

import RxSwift

import SnapKit
import Then

import DSKit
import Core

import AVFoundation

import AudioToolbox

public class MetronomeViewController: UIViewController {

    public var disposeBag = DisposeBag()

    private var viewModel: MetronomeViewModel

    private var colorChangeTimer: Timer?
    private let colors: [UIColor] = [.red, .yellow, .orange, .green, .blue, .purple]
    private var currentBitIndex = 0

    private lazy var navBar = MetronomeNavigationBar()

    private var exView = UIView().then {
        $0.backgroundColor = .clear
    }

    private let bpmTitle = UILabel().then {
        $0.textColor = DSKitAsset.Colors.blue400.color
        $0.font = UIFont.Pretendard.bodyLarge
        $0.text = "BPM"
    }

    private let tempoLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.Pretendard.light
    }

    private let tempoIncrementButton = UIButton().then {
        $0.setImage(DSKitAsset.Assets.selfCarePlus.image, for: .normal)
        $0.backgroundColor = DSKitAsset.Colors.gray50.color
        $0.layer.cornerRadius = 22.0
    }

    private let tempoDecrementButton = UIButton().then {
        $0.setImage(DSKitAsset.Assets.selfCareMinus.image, for: .normal)
        $0.backgroundColor = DSKitAsset.Colors.gray50.color
        $0.layer.cornerRadius = 22.0
    }

    private let tempoSlider = MGSlider()

    private let bitTitle = UILabel().then {
        $0.textColor = DSKitAsset.Colors.blue400.color
        $0.font = UIFont.Pretendard.bodyLarge
        $0.text = "비트수"
    }

    private var bitViews: [UIView] = []

    private lazy var bitPickerView = HorizontalPickerView().then {
        $0.pickerSelectValue = 3
        $0.delegate = self
    }

    private let vibrateButton = MGTimerButton(type: .vibration)
    private let stopButton = MGTimerButton(type: .stop, radius: 40.0)
    private let startButton = MGTimerButton(type: .start, radius: 40.0)
    private let soundButton = MGTimerButton(type: .sound)

    public init(viewModel: MetronomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        setupViews()
        setupActions()
        viewModel.tempo = 180
    }

    public func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }

    private func setupViews() {
        view.addSubviews([navBar, exView, bpmTitle])
        view.addSubviews([tempoLabel, tempoIncrementButton, tempoDecrementButton,
                          tempoSlider, bitTitle, bitPickerView])
        view.addSubviews([vibrateButton, stopButton, startButton, soundButton])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        exView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom).offset(20.0)
            $0.height.equalTo(177.0)
            $0.width.equalTo(350.0)
        }

        bpmTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(exView.snp.bottom).offset(40.0)
        }

        tempoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bpmTitle.snp.bottom).offset(10)
        }

        tempoIncrementButton.snp.makeConstraints {
            $0.centerY.equalTo(tempoLabel)
            $0.leading.equalTo(tempoLabel.snp.trailing).offset(10)
            $0.height.width.equalTo(44.0)
        }

        tempoDecrementButton.snp.makeConstraints {
            $0.centerY.equalTo(tempoLabel)
            $0.trailing.equalTo(tempoLabel.snp.leading).offset(-10)
            $0.height.width.equalTo(44.0)
        }

        tempoSlider.snp.makeConstraints {
            $0.width.equalTo(310.0)
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        bitTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tempoSlider.snp.bottom).offset(40.0)
        }

        bitPickerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bitTitle.snp.bottom).offset(10.0)
            $0.height.equalTo(48)
        }

        vibrateButton.snp.makeConstraints {
            $0.top.equalTo(bitPickerView.snp.bottom).offset(94.0)
            $0.leading.equalToSuperview().offset(83.0)
        }

        stopButton.snp.makeConstraints {
            $0.top.equalTo(bitPickerView.snp.bottom).offset(88.0)
            $0.leading.equalTo(vibrateButton.snp.trailing).offset(24.0)
        }

        startButton.snp.makeConstraints {
            $0.top.equalTo(bitPickerView.snp.bottom).offset(88.0)
            $0.leading.equalTo(vibrateButton.snp.trailing).offset(24.0)
        }

        soundButton.snp.makeConstraints {
            $0.top.equalTo(bitPickerView.snp.bottom).offset(94.0)
            $0.trailing.equalToSuperview().offset(-83.0)
        }
    }

    private func setupActions() {
        tempoIncrementButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.tempo += 1
                self?.updateTempoViews()
            })
            .disposed(by: disposeBag)

        tempoDecrementButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.tempo -= 1
                self?.updateTempoViews()
            })
            .disposed(by: disposeBag)

        startButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.start()
                self?.startColorChangeTimer()
                self?.updateTempoViews()
                self?.stopButton.isHidden = false
                self?.startButton.isHidden = true
            })
            .disposed(by: disposeBag)

        stopButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.stop()
                self?.colorChangeTimer?.invalidate()
                self?.resetBitViews()
                self?.stopButton.isHidden = true
                self?.startButton.isHidden = false
            })
            .disposed(by: disposeBag)

        vibrateButton.rx.tap
            .subscribe(onNext: { _ in
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            })
            .disposed(by: disposeBag)

        tempoSlider.rx.value
            .map { Int($0.rounded()) }
            .subscribe(onNext: { [weak self] roundedValue in
                self?.viewModel.tempo = roundedValue
                self?.updateTempoViews()
                self?.viewModel.stop()
                self?.colorChangeTimer?.invalidate()
                self?.resetBitViews()
            })
            .disposed(by: disposeBag)
    }

    private func startColorChangeTimer() {
        colorChangeTimer?.invalidate()
        colorChangeTimer = Timer.scheduledTimer(timeInterval: 60.0 / Double(viewModel.tempo),
                                                target: self, selector: #selector(updateBitViewsColor),
                                                userInfo: nil,
                                                repeats: true)
    }

    private func resetBitViews() {
        for bitView in bitViews {
            bitView.layer.removeAllAnimations()
            bitView.backgroundColor = .gray
        }
        currentBitIndex = 0
    }

    @objc private func updateBitViewsColor() {
        guard !bitViews.isEmpty else { return }

        UIView.animate(withDuration: 1.0) {
            for index in self.currentBitIndex..<self.bitViews.count {
                self.bitViews[index].backgroundColor = .gray
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.bitViews[self.currentBitIndex].backgroundColor == .gray {
                self.bitViews[self.currentBitIndex].backgroundColor = DSKitAsset.Colors.blue400.color
            }

            self.currentBitIndex += 1

            if self.currentBitIndex >= self.bitViews.count {
                self.currentBitIndex = 0
            }
        }
    }

    private func updateTempoViews() {
        tempoLabel.text = "\(viewModel.tempo)"
        tempoSlider.value = Float(viewModel.tempo)
    }
}

extension MetronomeViewController: MetronomeViewModelDelegate {
    public func didUpdateTempo(tempo: Int) {
        tempoLabel.text = "\(tempo)"
        tempoSlider.value = Float(tempo)
    }
}

extension MetronomeViewController: HorizontalPickerViewDelegate {
    public func didLevelChanged(selectedLevel: Int) {
        bitViews.forEach { $0.removeFromSuperview() }
        bitViews.removeAll()

        let viewWidth: CGFloat = 30.0
        var spacing: CGFloat = 0.0
        var rowCount: Int = 0

        switch selectedLevel {
        case 1...5:
            spacing = 40.0
            rowCount = selectedLevel
        case 6...7:
            spacing = 40.0
            rowCount = 3
        case 8...9:
            spacing = 40.0
            rowCount = 4
        case 10:
            spacing = 40.0
            rowCount = 5
        default:
            break
        }

        let viewHeight: CGFloat = viewWidth
        let totalWidth: CGFloat = CGFloat(rowCount) * viewWidth + CGFloat(rowCount - 1) * spacing
        let startingX: CGFloat = (view.frame.size.width - totalWidth) / 2.0

        colorChangeTimer?.invalidate()

        for bitView in bitViews {
            bitView.layer.removeAllAnimations()
            bitView.backgroundColor = .gray
        }
        currentBitIndex = 0

        for index in 0..<selectedLevel {
            let bitView = UIView()
            bitView.backgroundColor = .gray

            view.addSubview(bitView)
            bitViews.append(bitView)

            let leadingOffset = startingX + (CGFloat(index % rowCount) * (viewWidth + spacing))
            var topOffset = CGFloat(index / rowCount) * (viewHeight + spacing) + 100

            if index != 0 {
                topOffset += 10
            }

            bitView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(topOffset)
                make.leading.equalToSuperview().offset(leadingOffset)
                make.width.equalTo(viewWidth)
                if index == 0 {
                    make.height.equalTo(48)
                    bitView.layer.cornerRadius = 15
                } else {
                    make.height.equalTo(viewHeight)
                    bitView.layer.cornerRadius = viewWidth / 2.0
                }
            }
        }
        viewModel.beats = selectedLevel

        if viewModel.isPlaying {
            stopButton.isHidden = true
            startButton.isHidden = false
            viewModel.stop()
        }
    }
}
