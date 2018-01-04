//
//  RoundQueue.swift
//  Player
//
//  Created by Sitora on 02.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation
struct CircularQueue<T: Equatable> {
    fileprivate var items = [T]()
    fileprivate var pointer = 0
    var size: Int {
        return items.count
    }
    var isEmpty: Bool {
        return items.isEmpty
    }

    mutating func enque(value: T) {
        items.append(value)
    }

    mutating func peek() -> T? {
        if pointer == items.count {
            pointer = 0
        }
        pointer+=1
        return items[pointer - 1]
    }

    func first() -> T? {
        return items.first
    }

    func last() -> T? {
        return items.last
    }

    func get(at position: Int) -> T? {
        if position < items.count && position > 0 {
            return items[position]
        } else {
            return nil
        }
    }

    mutating func swap(_ firstElement: Int, _ secondElement: Int) {
        if !items.isEmpty &&
            firstElement < items.count &&
            secondElement < items.count {
            items.swapAt(firstElement, secondElement)
        }
    }

    mutating func swap(_ firstElement: T, _ secondElement: T) {
        if !items.isEmpty {
            guard let first = items.index(of: firstElement),
                let second = items.index(of: secondElement) else {
                    return
            }
            swap(first, second)
        }
    }
}
