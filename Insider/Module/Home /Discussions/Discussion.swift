//
//  Discussion.swift
//  Insider
//
//  Created by admin79 on 18/12/25.
//


import Foundation

struct Discussion {
    let id: UUID = UUID()        // A unique identifier for each post
    let title: String            // The text of the discussion
    let replyCount: Int         // Number of replies to show in the feed
    let date: Date               // Used to plot the discussion on your graph
    let wasStartedByMe: Bool     // Used to filter "Started by me" vs "Joined by me"
}