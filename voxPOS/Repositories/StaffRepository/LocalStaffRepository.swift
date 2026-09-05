//
//  LocalStaffRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

class LocalStaffRepository : StaffRepository {
    
    //This function is use in MVP only , this for mocking user when first time login
    func createStaff(staff: Staff) -> Bool {
        
        return false
    }
    
      
    func getStaff(username: String) -> Staff? {
        //
        
        return nil
    }
    
    func login(with username: String, password: String) -> Staff? {
        //
        return nil
    }
    
    

}
