//
//  NewInstructionViewModelTests.swift
//  TKVStoreTests
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import XCTest

@testable import TKVStore

final class NewInstructionViewModelTests: XCTestCase {
    var viewModel: NewInstructionViewModel!
    var mockOnSubmit: ((Instruction) -> Void)?
    
    override func setUp() {
        viewModel = NewInstructionViewModel(onSubmit: { [weak self] instruction in
            self?.mockOnSubmit?(instruction)
        })
        mockOnSubmit = nil
    }
    
    func testInitial() {
        XCTAssertEqual(viewModel.operation, .set)
        XCTAssertEqual(viewModel.key, "")
        XCTAssertEqual(viewModel.value, "")
        
        XCTAssertFalse(viewModel.isValid)
        XCTAssertTrue(viewModel.isKeyVisible)
        XCTAssertTrue(viewModel.isValueVisible)
    }
    
    func testValidateGet() {
        viewModel.operation = .get
        viewModel.key = "key"
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testValidateDelete() {
        viewModel.operation = .delete
        viewModel.key = "key"
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testValidateCount() {
        viewModel.operation = .count
        viewModel.value = "value"
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testValidateRollback() {
        viewModel.operation = .rollback
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testValidateCommit() {
        viewModel.operation = .commit
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testValidateBegin() {
        viewModel.operation = .begin
        XCTAssertTrue(viewModel.isValid)
    }
    
    func testValidateSet() {
        viewModel.operation = .set
        viewModel.key = "key"
        XCTAssertFalse(viewModel.isValid)
        
        viewModel.value = "value"
        XCTAssertTrue(viewModel.isValid)
        
        viewModel.key = ""
        XCTAssertFalse(viewModel.isValid)
    }
    
    func testFieldVisibility() {
        viewModel.operation = .set
        XCTAssertTrue(viewModel.isKeyVisible)
        XCTAssertTrue(viewModel.isValueVisible)

        viewModel.operation = .get
        XCTAssertTrue(viewModel.isKeyVisible)
        XCTAssertFalse(viewModel.isValueVisible)

        viewModel.operation = .delete
        XCTAssertTrue(viewModel.isKeyVisible)
        XCTAssertFalse(viewModel.isValueVisible)
        
        viewModel.operation = .count
        XCTAssertFalse(viewModel.isKeyVisible)
        XCTAssertTrue(viewModel.isValueVisible)
        
        viewModel.operation = .begin
        XCTAssertFalse(viewModel.isKeyVisible)
        XCTAssertFalse(viewModel.isValueVisible)
        
        viewModel.operation = .commit
        XCTAssertFalse(viewModel.isKeyVisible)
        XCTAssertFalse(viewModel.isValueVisible)
        
        viewModel.operation = .rollback
        XCTAssertFalse(viewModel.isKeyVisible)
        XCTAssertFalse(viewModel.isValueVisible)
    }
    
    func testDidTapAddSet() {
        genericTestDidTapAdd(expectedInstruction: .set(key: "k1", value: "v1")) {
            viewModel.operation = .set
            viewModel.key = "k1"
            viewModel.value = "v1"
        }
    }
    
    func testDidTapAddGet() {
        genericTestDidTapAdd(expectedInstruction: .get(key: "k1")) {
            viewModel.operation = .get
            viewModel.key = "k1"
        }
    }
    
    func testDidTapAddDelete() {
        genericTestDidTapAdd(expectedInstruction: .delete(key: "k1")) {
            viewModel.operation = .delete
            viewModel.key = "k1"
        }
    }
    
    func testDidTapAddCount() {
        genericTestDidTapAdd(expectedInstruction: .count(value: "hello")) {
            viewModel.operation = .count
            viewModel.value = "hello"
        }
    }
    
    func testDidTapAddBegin() {
        genericTestDidTapAdd(expectedInstruction: .begin) {
            viewModel.operation = .begin
        }
    }
    
    func testDidTapAddCommit() {
        genericTestDidTapAdd(expectedInstruction: .commit) {
            viewModel.operation = .commit
        }
    }
    
    func testDidTapAddRollback() {
        genericTestDidTapAdd(expectedInstruction: .rollback) {
            viewModel.operation = .rollback
        }
    }
        
    func testDidTapInvalidState() {
        mockOnSubmit = { instruction in
            XCTFail("should not be called")
        }
        
        viewModel.operation = .set
        viewModel.didTapAdd()
    }
        
    private func genericTestDidTapAdd(expectedInstruction: Instruction, configuration: () -> Void) {
        let didSubmitExpectation = expectation(description: "did submit")
        mockOnSubmit = { instruction in
            XCTAssertEqual(instruction, expectedInstruction)
            didSubmitExpectation.fulfill()
        }
        
        configuration()
        viewModel.didTapAdd()
        
        wait(for: [didSubmitExpectation], timeout: 0.1)
    }
}
