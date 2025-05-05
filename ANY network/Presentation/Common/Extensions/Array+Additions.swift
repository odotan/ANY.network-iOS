import Foundation

extension Array where Element == ContactInteraction {
    func findLowestMissingPriority() -> Int? {
        let missing = findAllMissingPriorities()
        return getLowestMissingPriority(missingPriorities: missing)
    }
    
    private func findAllMissingPriorities() -> [Int] {
        let priorities = self.compactMap { $0.priority }
        var missingPriorities = [Int]()
        
        for index in priorities.indices {
            guard index - 1 > -1 else { continue }
            
            let current = priorities[index]
            let last = priorities[index - 1]
            guard last != current else { continue }
            let priorityRangeBetweenLastAndCurrent = (last + 1)..<current
            
            if priorityRangeBetweenLastAndCurrent.count > 0 {
                missingPriorities.append(contentsOf: priorityRangeBetweenLastAndCurrent)
            }
        }
        
        return missingPriorities.filter { !$0.isMultiple(of: 4) }
    }
    
    private func getLowestMissingPriority(missingPriorities: [Int]) -> Int? {
        guard !missingPriorities.isEmpty, let lowestMissing = missingPriorities.min() else {
            return nil
        }
        
        return lowestMissing
    }
}
