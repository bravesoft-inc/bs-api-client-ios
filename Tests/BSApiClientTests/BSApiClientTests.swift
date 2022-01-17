import XCTest
import Combine
@testable import BSApiClient

@available(iOS 13.0.0, *)
final class BSApiClientTests: XCTestCase {
    
    var apiClient: BSApiClientPublisher?
    private var cancellables: [AnyCancellable] = []
    
    override func setUp() {
        super.setUp()
        
        apiClient = BSApiClientPublisher()
    }
    
    override func tearDown() {
        apiClient = nil
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    func testGetRequest() {
        let expect = expectation(description: "testGetRequest")
        
        let request = JokeRequest.getJoke
        apiClient!.fetch(request)
            .receive(on: DispatchQueue.main, options: nil)
            .sink { completion in
                switch completion {
                case .finished:
                    expect.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { (response: BSResponse<Joke>) in
                XCTAssert(response.body?.joke != nil)
            }
            .store(in: &cancellables)
        
        wait(for: [expect], timeout: TimeInterval(apiClient!.waitTime))
    }
    
    func testPostRequest() {
    }
}
