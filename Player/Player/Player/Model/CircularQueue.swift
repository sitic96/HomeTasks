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

    var itemsArray: [T] {
        return items
    }

    var size: Int {
        return items.count
    }
    var isEmpty: Bool {
        return items.isEmpty
    }
    var currentPosition: Int {
        return pointer
    }

    mutating func enque(value: T) {
        items.append(value)
    }

    mutating func peek() -> T? {
        if !items.isEmpty {
            if pointer == items.count {
                pointer = 0
            }
            pointer+=1
            return items[pointer - 1]
        } else {
            return nil
        }
    }

    func first() -> T? {
        return items.first
    }

    func last() -> T? {
        return items.last
    }

    func get(at position: Int) -> T? {
        if position < items.count && position >= 0 {
            return items[position]
        } else {
            return nil
        }
    }

    func current() -> T? {
        return items[pointer - 1]
    }

    func contains(_ item: T) -> Bool {
        return items.contains(item)
    }
    
    mutating func removeAll() {
        items.removeAll()
    }

    mutating func changePointerPosition(with newPosition: Int) {
        if newPosition>=0 && newPosition<items.count {
            pointer = newPosition
        }
    }

    mutating func remove(_ item: T) {
        if let removeItemIndex = items.index(of: item) {
            items.remove(at: removeItemIndex)
        }
    }

    mutating func movePointerBack() {
        if pointer == 0 {
            // минус 2 т.к. после каждой выдачи элемента указатель сразу смещается на следующий
            //            элемент и для получения предыдущего нам нужно сделать шаг назад
            //            относительно используемого в данный момент
            //            то есть два шага назад от того, на который указывает указатель
            pointer = size - 2
        } else if pointer == 1 {
            pointer = size - 1
        } else {
            pointer-=2
        }
    }
}
