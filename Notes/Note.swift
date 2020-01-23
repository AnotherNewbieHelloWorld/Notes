//
//  Note.swift
//  Notes
//
//  Created by Apple User on 16.01.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation
import SQLite3

struct Note{
    let id: Int
    var contents: String
}

// SINGLETON means that we have this class but there's only ever going to be one instance of it
class NoteManager {
    var database: OpaquePointer!
    
    // What a SINGLETON looks like?
    // by saying STATIC that basically enables you to access this property without an instance
    static let main = NoteManager()
    
    private init(){
    }
    
    // The method to connect to a database
    func connect() {
        if database != nil {
            return
        }
        // get a path to some file on the users phone
        do {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("notes.sqlite3")
            // establish a connection to the database
            // & - we want to give a pointer to this function or "here's the adress of where I want you to store this connection to the database"
            if sqlite3_open(databaseURL.path, &database) == SQLITE_OK{
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS notes (contents TEXT)", nil, nil, nil) == SQLITE_OK {
                }
                else { print("Could not create table") }
            }
            else { print("Could not connect") }
        }
        catch { print("Could not create database") }
    }
    
    // Insert a new note to a database
    func create() -> Int {
        connect()
        var statement: OpaquePointer!
        // prepare the query
        // & == "get the adress"
        if sqlite3_prepare_v2(database, "INSERT INTO notes (contents) VALUES ('New note')", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
            return -1
        }
        //execute the query
        if sqlite3_step(statement) != SQLITE_DONE{
            print("Could not insert note")
            return -1
        }
        // finalize it (can't use this pointer again)
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    // Get all of the contents from the database
    func getAllNotes() -> [Note] {
        connect()
        var statement: OpaquePointer!
        var result: [Note] = []
        // prepate the query
        if sqlite3_prepare_v2(database, "SELECT rowid, contents FROM notes", -1, &statement, nil) != SQLITE_OK{
            print("Error creting select")
            return []
        }
        // execute the query (this time need to read all available rows)
        while sqlite3_step(statement) == SQLITE_ROW {
            result.append(Note(id: Int(sqlite3_column_int(statement, 0)), contents: String(cString: sqlite3_column_text(statement, 1))))
        }
        // cleanup behind the scenens
        sqlite3_finalize(statement)
        return result
    }
    
    func save(note: Note){
        connect()
        var statement: OpaquePointer!
        
        // this '?' marks here are just a nice way of passing data into a query
        // string interpolation is insecure cos you're opening yourself up to someone sort of doing things with your app that you might not want them to (basically, to a sql injection attack)
        // parameter binding for safe
        if sqlite3_prepare_v2(database, "UPDATE notes SET contents = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK{
            print("Error creating update statement")
            return
        }
        // to bind data to this query
        sqlite3_bind_text(statement, 1, NSString(string: note.contents).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(note.id))
        
        // execute
        if sqlite3_step(statement) != SQLITE_DONE{
            print("Error running update")
        }
        
        // finalize
        sqlite3_finalize(statement)
    }
}
