public struct Report{
    var country: String
    var country_code: String
    var slug: String
    var new_confirmed: Int64
    var total_confirmed: Int64
    var new_deaths: Int64
    var total_deaths: Int64
    var new_recovered: Int64
    var total_recovered: Int64
    var date : String
    
    init(country:String, country_code:String, slug:String, new_confirmed:Int64, total_confirmed:Int64, new_deaths:Int64, total_deaths:Int64, new_recovered:Int64, total_recovered: Int64, date: String) {
        
        self.country = country
        self.country_code = country_code
        self.slug = slug
        self.new_confirmed = new_confirmed
        self.total_confirmed = total_confirmed
        self.new_deaths = new_deaths
        self.total_deaths = total_deaths
        self.new_recovered = new_recovered
        self.total_recovered = total_recovered
        self.date = date
    }
    
    init() {
        self.country = ""
        self.country_code = ""
        self.slug = ""
        self.new_confirmed = 0
        self.total_confirmed = 0
        self.new_deaths = 0
        self.total_deaths = 0
        self.new_recovered = 0
        self.total_recovered = 0
        self.date = "00-00-00"
    }
}
