//
//  InMemoryStorageTests.swift
//  TKVStoreTests
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import XCTest

@testable import TKVStore

final class InMemoryStorageTests: XCTestCase {
    private var storage: InMemoryStorage!
    
    override func setUp() {
        storage = InMemoryStorage()
    }
    
    func testGetInvalidKey() {
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .warning("key not set"))
    }
    
    func testSet() {
        XCTAssertNil(storage.perform(instruction: .set(key: "key1", value: "value 1")))
    }
    
    func testReset() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        storage.reset()
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .warning("key not set"))
    }
    
    func testGetValidKey() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value"))
    }
    
    func testDeleteNonExisting() {
        XCTAssertNil(storage.perform(instruction: .delete(key: "key1")))
    }
    
    func testDeleteExisting() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .delete(key: "key1")))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .warning("key not set"))
    }
    
    func testCountEmpty() {
        XCTAssertEqual(storage.perform(instruction: .count(value: "value")), .output("0"))
    }
    
    func testCountSkipNotMatching() {
        storage.perform(instruction: .set(key: "key1", value: "value 1"))
        XCTAssertEqual(storage.perform(instruction: .count(value: "value")), .output("0"))
    }
    
    func testCountMatching() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertEqual(storage.perform(instruction: .count(value: "value")), .output("1"))
    }
    
    func testCountMatchingMixed() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        storage.perform(instruction: .set(key: "key2", value: "value1"))
        storage.perform(instruction: .set(key: "key3", value: "value"))
        XCTAssertEqual(storage.perform(instruction: .count(value: "value")), .output("2"))
    }
    
    func testCountAfterDelete() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        storage.perform(instruction: .set(key: "key2", value: "value1"))
        storage.perform(instruction: .set(key: "key3", value: "value"))
        storage.perform(instruction: .delete(key: "key3"))
        
        XCTAssertEqual(storage.perform(instruction: .count(value: "value")), .output("1"))
    }
    
    func testTransactionValuesBeforeBegin() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .begin))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value"))

    }
    
    func testTransactionValuesAfterCommit() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .begin))
        XCTAssertNil(storage.perform(instruction: .commit))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value"))
    }
    
    func testTransactionOverwriteValuesInsideTransaction() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .begin))
        storage.perform(instruction: .set(key: "key1", value: "value2"))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value2"))
        XCTAssertNil(storage.perform(instruction: .commit))
    }
    
    func testTransactionOverwriteValuesAfterCommit() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .begin))
        storage.perform(instruction: .set(key: "key1", value: "value2"))
        XCTAssertNil(storage.perform(instruction: .commit))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value2"))
    }
    
    func testTransactionRollbackToKeepUnmoidifiedValues() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .begin))
        XCTAssertNil(storage.perform(instruction: .rollback))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value"))
    }
    
    func testTransactionRollbackToKeepOldValue() {
        storage.perform(instruction: .set(key: "key1", value: "value"))
        XCTAssertNil(storage.perform(instruction: .begin))
        storage.perform(instruction: .set(key: "key1", value: "value2"))
        XCTAssertNil(storage.perform(instruction: .rollback))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value"))
    }
    
    func testNestedTransactionRollbackToKeepOldValue() {
        storage.perform(instruction: .set(key: "key1", value: "value1"))
        if true { // just for indentation
            storage.perform(instruction: .begin)
            storage.perform(instruction: .set(key: "key1", value: "value2"))
            
            if true {
                storage.perform(instruction: .begin)
                storage.perform(instruction: .set(key: "key1", value: "value3"))
                XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
                XCTAssertNil(storage.perform(instruction: .rollback))
            }
            
            XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value2"))
            XCTAssertNil(storage.perform(instruction: .rollback))
            XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value1"))
        }
        XCTAssertEqual(storage.perform(instruction: .commit), .warning("no transaction"))
    }
    
    func testNestedTransactionCommitInner() {
        storage.perform(instruction: .set(key: "key1", value: "value1"))
        
        if true { // just for indentation
            storage.perform(instruction: .begin)
            storage.perform(instruction: .set(key: "key1", value: "value2"))
            
            if true {
                storage.perform(instruction: .begin)
                storage.perform(instruction: .set(key: "key1", value: "value3"))
                XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
                XCTAssertNil(storage.perform(instruction: .commit))
            }
            
            XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
            XCTAssertNil(storage.perform(instruction: .rollback))
        }
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value1"))
    }
    
    func testNestedTransactionRollbackInner() {
        storage.perform(instruction: .set(key: "key1", value: "value1"))
        
        if true { // just for indentation
            storage.perform(instruction: .begin)
            storage.perform(instruction: .set(key: "key1", value: "value2"))
            
            if true {
                storage.perform(instruction: .begin)
                storage.perform(instruction: .set(key: "key1", value: "value3"))
                XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
                XCTAssertNil(storage.perform(instruction: .rollback))
            }
            
            XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value2"))
            XCTAssertNil(storage.perform(instruction: .commit))
        }
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value2"))
    }
    
    func testNestedTransactionCount() {
        storage.perform(instruction: .set(key: "key1", value: "value1"))
        
        if true { // just for indentation
            storage.perform(instruction: .begin)
            storage.perform(instruction: .set(key: "key1", value: "value2"))
            
            if true {
                storage.perform(instruction: .begin)
                storage.perform(instruction: .set(key: "key1", value: "value3"))
                
                XCTAssertEqual(storage.perform(instruction: .count(value: "value3")), .output("1"))
                XCTAssertEqual(storage.perform(instruction: .count(value: "value2")), .output("0"))
                XCTAssertEqual(storage.perform(instruction: .count(value: "value1")), .output("0"))
                XCTAssertNil(storage.perform(instruction: .rollback))
            }
            
            XCTAssertEqual(storage.perform(instruction: .count(value: "value3")), .output("0"))
            XCTAssertEqual(storage.perform(instruction: .count(value: "value2")), .output("1"))
            XCTAssertEqual(storage.perform(instruction: .count(value: "value1")), .output("0"))
            
            XCTAssertNil(storage.perform(instruction: .commit))
        }
        
        XCTAssertEqual(storage.perform(instruction: .count(value: "value3")), .output("0"))
        XCTAssertEqual(storage.perform(instruction: .count(value: "value2")), .output("1"))
        XCTAssertEqual(storage.perform(instruction: .count(value: "value1")), .output("0"))

    }
    
    func testNestedTransactionCommitOutter() {
        storage.perform(instruction: .set(key: "key1", value: "value1"))
        storage.perform(instruction: .begin)
        storage.perform(instruction: .set(key: "key1", value: "value2"))
        storage.perform(instruction: .begin)
        storage.perform(instruction: .set(key: "key1", value: "value3"))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
        XCTAssertNil(storage.perform(instruction: .commit))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
        XCTAssertNil(storage.perform(instruction: .commit))
        XCTAssertEqual(storage.perform(instruction: .get(key: "key1")), .output("value3"))
    }
    
    func testTransactionRollbackWithoutBegin() {
        XCTAssertEqual(storage.perform(instruction: .rollback), .warning("no transaction"))
    }
    
    func testTransactionCommitWithoutBegin() {
        XCTAssertEqual(storage.perform(instruction: .commit), .warning("no transaction"))
    }
}
