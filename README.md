# Requirements:

### Unit tests
* Write unit tests to check proper functionality of all business logic. Test for both success and failure.
* Write unit tests to sanity check all view controllers and custom views ([country cell](./CountriesChallenge/Views/CountryCell.swift)).
* Bonus points: Write unit tests for the networking code.

### UI tests
* Write UI tests for all the screens (countries list and country detail) to check proper functionality.
* Bonus points: Write UI tests for the search functionality.

# Acceptance criteria:
* A minimum of 80% test coverage is expected. Bonus points for 90%+ coverage.

# NOTES
* The current implementation may require some refactoring to be properly testable.
* Please zip up your Xcode project and email it — do not post on GitHub. Thanks.


# TEST RESULTS

## Failed Test Cases

---

### 1. `test_fetchCountries_withInvalidURL_shouldThrowInvalidURLError`

- **Module**: `CountriesServiceTests`  
- **File**: `CountriesServiceTests2.swift:77`  
- **Execution Time**: `0.013s`

#### **Test Objective**
Verify that the `fetchCountries` method throws an `.invalidUrl` error when supplied with an invalid URL string.

#### **Actual Result**
Method threw a `.decodingFailure` instead of `.invalidUrl`.

#### **Root Cause**
- Invalid URL string is not validated early.
- Networking proceeds and fails during decoding of empty/unexpected response, hence `.decodingFailure`.

#### **Fix Recommendation**
Add URL validation before proceeding:
```swift
guard let url = URL(string: urlString), url.scheme != nil else {
    completion(.failure(.invalidUrl))
    return
}
```
##  2. test_fetchCountries_withNilData_shouldThrowInvalidDataError

- **Module**: CountriesServiceTests  
- **File**: CountriesServiceTests2.swift:93  
- **Execution Time**: 0.004 s

### Test Objective  
To ensure the method correctly throws an `.invalidData` error when the API returns a nil or empty data object.

### Actual Result  
The function returned a `.decodingFailure` instead of `.invalidData`.

### Root Cause  
The logic attempts decoding before checking if the data is `nil` or empty.  
This leads to the decoding error overriding the intended `.invalidData` safeguard.

### Fix Recommendation  
Insert explicit data validation prior to decoding:

```swift
guard let data = data, !data.isEmpty else {
    completion(.failure(.invalidData))
    return
}
```

## 3. testRefreshCountries_setsErrorThenSuccess

- **Module**: CountriesViewModelTests  
- **File**: CountriesViewModelTests.swift:208  
- **Execution Time**: 0.009 s

### Test Objective  
Simulates a ViewModel scenario where an error (e.g., `.invalidData`) is initially encountered, followed by a successful fetch.  
The ViewModel should clear the error upon success.

### Actual Result  
Assertion failed because `viewModel.error` still held `"invalidData"` after the supposed success.

### Root Cause  
The ViewModel likely updates the data list but does not reset the error state on a successful call.  
The residual error state causes the test to fail.

### Fix Recommendation  
Ensure that the error is explicitly reset in the success path:

```swift
self.error = nil
self.countries = fetchedCountries
```



## 📊 Additional Observations

| Test Category           | Total | Passed | Failed | Coverage |
|------------------------|-------|--------|--------|----------|
| Service Layer Tests     | 10    | 8      | 2      | 80%      |
| ViewModel Logic Tests   | 19    | 18     | 1      | 95%      |
| UI/Integration Tests    | 46    | 46     | 0      | 100%     |


### `For deatiled summary`: Please refer the "Testing documentation" pdf
