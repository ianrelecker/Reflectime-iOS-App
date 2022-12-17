//
//  Motivations.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 11/26/22.
//

import Foundation

func motivations() -> String {
    var motivation = ["Write down what you are thinking about now. Could be issues you are having, something you want, goals you are working to. \n \nWrite down what you are thinking, reflect on your thoughts.", "Try seperating your thoughts into different sections. If your main thought is a difficulty, what part of your life is this in?", "Be honest with yourself, if you think something isn't going right, reflect on that. What is the issue you are running into? How would someone else deal with this?", "What are you celebrating today? What was something you learned, got better at, or practiced?", "What is a long term project of yours?", "Who are you comparing yourself to? Is this healthy?", "Why are you amazing!", "What is the best thing that has happened today?", "What did you just complete?", "What are you looking forward to?", "How can you make this next week better than the last?", "What do you want more of?", "You are the best.", "How was your day?", "Reflect on the most impactful thing you did.", "Reflect on what made you upset.", "Reflect on what made you happy.", "Reflect on what you are proud of."]
    
    motivation.shuffle()
    return motivation[0]
}


