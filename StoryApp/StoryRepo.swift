//
//  StoryRepo.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/30/16.
//  Copyright © 2016 usharif. All rights reserved.
//

class StoryRepo {
    var arrayOfStories : [Story]
    
    init() {
        arrayOfStories = []
        arrayOfStories.append(Story(name: "Horror", text: "Horror Story \nLorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vitae velit non neque tempor interdum a at libero. Sed vehicula dignissim leo, sed tempus nisi elementum feugiat. Nulla rhoncus facilisis varius. Nulla laoreet at eros nec porta. Phasellus vitae velit sed metus maximus mattis non nec augue. In gravida dictum neque a venenatis. Morbi quis tellus fringilla, pellentesque sapien sed, faucibus eros. Proin vestibulum justo id porttitor bibendum.\n", fact: true))
        arrayOfStories.append(Story(name: "Drama", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vitae velit non neque tempor interdum a at libero. Sed vehicula dignissim leo, sed tempus nisi elementum feugiat. Nulla rhoncus facilisis varius. Nulla laoreet at eros nec porta. Phasellus vitae velit sed metus maximus mattis non nec augue. In gravida dictum neque a venenatis. Morbi quis tellus fringilla, pellentesque sapien sed, faucibus eros. Proin vestibulum justo id porttitor bibendum.", fact: false))
        arrayOfStories.append(Story(name: "Comedy", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vitae velit non neque tempor interdum a at libero. Sed vehicula dignissim leo, sed tempus nisi elementum feugiat. Nulla rhoncus facilisis varius. Nulla laoreet at eros nec porta. Phasellus vitae velit sed metus maximus mattis non nec augue. In gravida dictum neque a venenatis. Morbi quis tellus fringilla, pellentesque sapien sed, faucibus eros. Proin vestibulum justo id porttitor bibendum.", fact: true))
        arrayOfStories.append(Story(name: "Sci-fi", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vitae velit non neque tempor interdum a at libero. Sed vehicula dignissim leo, sed tempus nisi elementum feugiat. Nulla rhoncus facilisis varius. Nulla laoreet at eros nec porta. Phasellus vitae velit sed metus maximus mattis non nec augue. In gravida dictum neque a venenatis. Morbi quis tellus fringilla, pellentesque sapien sed, faucibus eros. Proin vestibulum justo id porttitor bibendum.", fact: false))
    }
}
