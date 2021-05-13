/*
   Storing global variables between class
 */
import Foundation

//country profile that currently selected to view
public var viewing_country: String = ""
//if dark mode is switched on/off
public var dark_mode = false

public var UD = UserData()

public var internetIsOn = true

public var serverIsOn = true

public var appHasLoaded = false

public var usingBackupData = false

public let defaults = UserDefaults.standard

public var lastPage = ""
