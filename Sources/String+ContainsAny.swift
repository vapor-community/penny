extension String {
    func contains(any strings: String...) -> Bool {
        for string in strings where self.contains(string) { return true }
        return false
    }
}
