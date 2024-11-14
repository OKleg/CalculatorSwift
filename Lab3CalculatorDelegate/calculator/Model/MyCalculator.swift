//
//  MyCalculator.swift
//  calculator
//
//  Created by student on 03.10.2024.
//  Copyright © 2024 Илья Лошкарёв. All rights reserved.
//

import Foundation

public class MyCalculator: Calculator {
    
    /// Представитель – объект, реагирующий на изменение внутреннего состояния калькулятора
    public var delegate: CalculatorDelegate?
    
    // Хранимое выражение: <левое значение> <операция> <правое значение>
    
    /// Левое значение - обычно хранит результат предыдущей операции
    public var result: Double? = 0
    /// Текущая операция
    public var operation: Operation?
    /// Правое значение - к нему пользователь добавляет цифры
    public var input: Double? = 0
    
    /// Правое значение содержит точку
    public var hasPoint: Bool = false
    /// Количество текущих знаков после запятой в правом значении
    public var fractionDigits: UInt = 0
    /// `inputLength` – максимальная длина поля ввода (количество символов)
    private let maxInputLength: UInt
    /// `fractionLength` – максимальное количество знаков после заятой
    private let maxFractionLength: UInt
    /// Инициализатор
    /// `inputLength` – максимальная длина поля ввода (количество символов)
    /// `fractionLength` – максимальное количество знаков после заятой
    required public init(inputLength len: UInt, maxFraction frac: UInt) {
        self.maxInputLength = len
        self.maxFractionLength = frac
        self.result = 0
        self.input = 0
        self.operation = nil
        self.hasPoint = false
        self.fractionDigits = 0
    }
    
    /// Добавить цифру к правому значению
    public func addDigit(_ d: Int) {
        input = input ?? 0
        if String(self.input!).count >= maxInputLength {
            delegate?.calculatorDidInputOverflow(self)
            return
        }
        if hasPoint {
                input = input! + Double(d) / pow(10.0, Double(fractionDigits + 1))
                fractionDigits += 1
        } else {
            input = input! * 10 + Double(d)
        }
        delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
    }
    
    /// Добавить точку к правому значению
    public func addPoint() {
        if hasPoint { return }
        else {hasPoint = true}
    }
    
    /// Добавить операцию,
    ///  если операция уже задана, вычислить предыдущее значение
    public func addOperation(_ op: Operation) {
        if operation != nil {
            compute()
            operation = op
            return
        }
        if (op == .sign) {
            input = input! * -1
            delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
            return
        }
        operation = op
        if input != 0 {
            result = input
            input = 0
            hasPoint = false
            fractionDigits = 0
        }
    }
    
    // Вычислить значение выражения и записать его в левое значение
    public func compute() {
        if operation == nil {
            delegate?.calculatorDidNotCompute(self, withError: "operation not found")
            input = result!
            return
        }
        var res: Double = 0
        
        switch operation! {
        case .add:
            res = result! + input!
        case .sub:
            res = result! - input!
        case .mul:
            res = result! * input!
        case .div:
            if input == 0 {
                delegate?.calculatorDidNotCompute(self, withError: "can't divvide by zero")
                operation = nil
                return
            }
            res = result! / input!
            
        case .perc:
            res = result! * input! / 100
        case .sign:
            res = input! * -1
            break
            
        }
        result = res
        
        let fraction = modf(res)
        print(String(fraction.1))
        fractionDigits = min(UInt(String(fraction.1).count-2), maxFractionLength)
        
        delegate?.calculatorDidUpdateValue(self, with: result!, valuePrecision: fractionDigits)
        input = 0
        operation = nil
        hasPoint = false
        fractionDigits = 0
    }
    /// Очистить правое значение
    public func clear() {
        input = 0
        hasPoint = false
        fractionDigits = 0
        delegate?.calculatorDidClear(self, withDefaultValue: 0, defaultPrecision: fractionDigits)
        
    }
    /// Очистить всё выражение
    public func reset() {
        result = 0
        operation = nil
    }
//    private func unZero(_ d: Double){
//        while d % 10 == 0
//                d =d/ 10
//
//    }
}
