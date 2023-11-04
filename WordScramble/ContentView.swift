//
//  ContentView.swift
//  WordScramble
//
//  Created by Мирсаит Сабирзянов on 04.11.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            List{
                Section("Score: \(usedWords.count)"){
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(usedWords,id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar{
                Button("Restart game", action: startGame)
            }
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord(){
        let ans = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard ans.count > 0 else{return}
        
        guard isShortestOfThree(word: ans) else {
            wordError(title: "A short word", message: "Enter a word longer than three letters")
            return
        }
        guard isNotRootWord(word: ans) else {
            wordError(title: "This is the original word", message: "Enter a word other than the original one")
            return
        }
        
        guard isPossible(word: ans) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: ans) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isOriginal(word: ans) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        withAnimation{
            usedWords.insert(ans, at: 0)
        }
        newWord = ""
    }
    
    func startGame(){
        usedWords = []
        newWord = ""
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            if let startWords = try? String(contentsOf: startWordUrl){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "billions"
                return
            }
        }
        fatalError("Error")
    }
    
    func isOriginal(word: String) -> Bool{
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let ind = tempWord.firstIndex(of: letter){
                tempWord.remove(at: ind)
            }
            else{
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isShortestOfThree(word: String) -> Bool{
        word.count > 2
    }
    
    func isNotRootWord(word: String) -> Bool{
        word != rootWord
    }
}

#Preview {
    ContentView()
}
