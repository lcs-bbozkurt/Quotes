//
//  ContentView.swift
//  Quotes
//
//  Created by Berk Bozkurt on 2022-02-22.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    @State var currentQuote: Quote = Quote(quoteText: "Hello",
                                           quoteAuthor: "Berk")
    @State var currentQuoteAddedToFavourites: Bool = false
    
    // MARK: Computed Properties
    
    var body: some View {
        VStack {
            Text(currentQuote.quoteText)
            Text(currentQuote.quoteAuthor)
        }
        .task {
            await loadNewQuote()
        }
    }
    
    // MARK: Functions
    func loadNewQuote() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://api.forismatic.com/api/1.0/?method=getQuote&key=457653&format=json&lang=en")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentQuote = try JSONDecoder().decode(Quote.self, from: data)
            
            // Reset the flag that tracks whether the current joke
            // is a favourite
           //f currentJokeAddedToFavourites = false
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
