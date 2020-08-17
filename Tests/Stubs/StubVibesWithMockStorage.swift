class StubVibesWithMockStorage: Vibes {
    override class func getStorageWith(type: VibesStorageEnum) -> LocalStorageType {
        return StubStorage()
    }
}
