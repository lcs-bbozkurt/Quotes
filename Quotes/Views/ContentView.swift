//
//  ContentView.swift
//  Quotes
//
//  Created by Berk Bozkurt on 2022-02-22.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    @Environment(\.scenePhase) var scenePhase
    
    
    @State var currentQuote: Quote = Quote(quoteText: "Hello",
                                           quoteAuthor: "Berk")
    @State var favourites: [Quote] = []   // empty list to start
    
    @State var currentQuoteAddedToFavourites: Bool = false
    
    // MARK: Computed Properties
    
    var body: some View {
        VStack {
            VStack {
                
                Text(currentQuote.quoteText)
                    .font(.title)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .padding(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary, lineWidth: 4)
                    )
                    .padding(10)
                
                Image(systemName: "heart.circle")
                    .font(.largeTitle)
                //                      CONDITION                        true   false
                    .foregroundColor(currentQuoteAddedToFavourites == true ? .red : .secondary)
                    .onTapGesture {
                        
                        // Only add to the list if it is not already there
                        if currentQuoteAddedToFavourites == false {
                            
                            // Adds the current joke to the list
                            favourites.append(currentQuote)
                            
                            // Record that we have marked this as a favourite
                            currentQuoteAddedToFavourites = true
                            
                        }
                        
                    }
                
                Button(action: {
                    
                    // The Task type allows us to run asynchronous code
                    // within a button and have the user interface be updated
                    // when the data is ready.
                    // Since it is asynchronous, other tasks can run while
                    // we wait for the data to come back from the web server.
                    Task {
                        // Call the function that will get us a new quote!
                        await loadNewQuote()
                    }
                }, label: {
                    Text("Another one!")
                })
                    .buttonStyle(.bordered)
                
                HStack {
                    Text("Favourites")
                        .bold()
                    
                    Spacer()
                }
                
                // Iterate over the list of favourites
                // As we iterate, each individual favourite is
                // accessible via "currentFavourite"
                List(favourites, id: \.self) { currentFavourite in
                    Text(currentFavourite.quoteText)
                }
                
                Spacer()
                
            }
            .task {
                
                // Load a joke from the endpoint!
                // We "calling" or "invoking" the function
                // named "loadNewJoke"
                // A term for this is the "call site" of a function
                // What does "await" mean?
                // This just means that we, as the programmer, are aware
                // that this function is asynchronous.
                // Result might come right away, or, take some time to complete.
                // ALSO: Any code below this call will run before the function call completes.
                await loadNewQuote()
                
                print("I tried to load a new joke")
                
                // Load the favourites from the file saved on the device
                loadQuotes()
            }
            // React to changes of state for the app. (foreground, inactive, background)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                } else {
                    print("Background")
                    // Permanently save the list of tasks
                    persistQuotes()
                }
            }
            .navigationTitle("icanhazdadjoke?")
            .padding()
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
            // Takes what is in "data" and tries to put it into "currentQuote"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentQuote = try JSONDecoder().decode(Quote.self, from: data)
            
            // Reset the flag that tracks whether the current joke
            // is a favourite
             currentQuoteAddedToFavourites = false
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
        
    }
    func persistQuotes() {
        // Get a location under which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedQuotesLabel)
        print(filename)
        // Try to encode the data in our list of favourites to JSON
        do {
            // Create a JSONEncoder()
            let encoder = JSONEncoder()
            // Configured the encoder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            // encode the list of favourites we have collect
            let data = try encoder.encode(favourites)
            // Write the JSON to a file in the filename location we came up with earlier.
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            // See the data that was written
            print("Saved data to the Documents directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
        } catch {
            print("Unable to write list of favourites to the Documents directory")
            print("=======")
            print(error.localizedDescription)
        }
    }
    func loadQuotes() {
        // Get a location under which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedQuotesLabel)
        print(filename)
        // Attempt to load the data
        do {
            // load the row data
            let data = try Data(contentsOf: filename)
            // See the data that was written
            print("Saved data to the Documents directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
            // Decode the JSON into Swift native data structures.
            // NOTE: We use [Quote] since we are loading into a list (array)
            favourites = try JSONDecoder().decode([Quote].self, from: data)
        } catch {
            // What went wrong
            print("Could not load the data from the JSON file")
            print("====")
            print(error.localizedDescription)
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
