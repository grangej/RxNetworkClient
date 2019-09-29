//
//  ObservableType+Reachability.swift
//  Pods
//
//  Created by Ivan Bruel on 22/03/2017.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//
//

import Foundation
import Reachability
import RxSwift
import RxCocoa 

public extension ObservableType {
    /// Retries the source observable sequence on error using a provided retry
    /// strategy.
    /// - parameter maxAttemptCount: Maximum number of times to repeat the
    /// sequence. `Int.max` by default.
    /// - parameter didBecomeReachable: Trigger which is fired when network
    /// connection becomes reachable.
    /// - parameter shouldRetry: Always retruns `true` by default.
    func retryOnConnect(_ maxAttemptCount: Int = Int.max,
               delay: DelayOptions = DelayOptions.exponential(initial: 5, multiplier: 2, maxDelay: 90),
               didBecomeReachable: Signal<Void> = Reachability.rx.isConnected.asSignal(onErrorJustReturn: ()),
               shouldRetry: @escaping (Error) -> Bool = { return $0.shouldRetry }) -> Observable<Element> {

        return retryWhen { (errors: Observable<Error>) in

            return errors.enumerated().flatMap { attempt, error -> Observable<Void> in

                guard shouldRetry(error), maxAttemptCount > attempt + 1 else {
                    return .error(error)
                }

                let timer = Observable<Int>.timer(
                    delay.make(attempt + 1).dispatchInterval,
                    scheduler: MainScheduler.instance
                    ).map { _ in () } // cast to Observable<Void>
                return Observable.merge(timer, didBecomeReachable.asObservable())
            }
        }
    }

    func retryServerError(_ maxAttemptCount: Int = Int.max,
        delay: DelayOptions = DelayOptions.exponential(initial: 5, multiplier: 2, maxDelay: 90),
        shouldRetry: @escaping (Error) -> Bool = { return $0.shouldRetry }) -> Observable<Element> {

        return retryWhen { (errors: Observable<Error>) in

            return errors.enumerated().flatMap { attempt, error -> Observable<Void> in

                guard shouldRetry(error), maxAttemptCount > attempt + 1 else {
                    return .error(error)
                }

                let timer = Observable<Int>.timer(
                    delay.make(attempt + 1).dispatchInterval,
                    scheduler: MainScheduler.instance
                    ).map { _ in () } // cast to Observable<Void>
                return timer
            }
        }
    }

}

public enum DelayOptions {
    case immediate
    case constant(time: Double)
    case exponential(initial: Double, multiplier: Double, maxDelay: Double)
    case custom(closure: (Int) -> Double)
}

public extension DelayOptions {
    func make(_ attempt: Int) -> Double {
        switch self {
        case .immediate: return 0.0
        case .constant(let time): return time
        case .exponential(let initial, let multiplier, let maxDelay):
            // if it's first attempt, simply use initial delay, otherwise calculate delay
            let delay = attempt == 1 ? initial : initial * pow(multiplier, Double(attempt - 1))
            return min(maxDelay, delay)
        case .custom(let closure): return closure(attempt)
        }
    }
}


public extension TimeInterval {
    var dispatchInterval: DispatchTimeInterval {
        let microseconds = Int64(self * TimeInterval(USEC_PER_SEC)) // perhaps use nanoseconds, though would more often be > Int.max
        return microseconds < Int.max ? DispatchTimeInterval.microseconds(Int(microseconds)) : DispatchTimeInterval.seconds(Int(self))
    }
}
