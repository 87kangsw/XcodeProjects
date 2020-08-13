//
//  MainView.swift
//  StatusBuddy
//
//  Created by Dima Kalachniuk on 09/03/2020.
//  Copyright © 2020 com.dkcompany.xcodeprojects. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @State private var searchTerm = ""
    @EnvironmentObject var preferences: Preferences

    private var projects: [Project] {
        preferences.projects.filter({ searchTerm.isEmpty ? true : $0.name.lowercased().contains(searchTerm.lowercased()) })
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $searchTerm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer().frame(width: 10)
                AddProjectButton(action: addProject)
                Spacer().frame(width: 10)
                PreferencesView()
            }.padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))

            Divider().padding([.top], 3)

            if projects.isEmpty {
                Spacer()
                if searchTerm.isEmpty {
                    VStack {
                        HStack {
                            Text("Please add a project")
                            AddProjectButton(action: addProject)
                        }
                    }

                } else {
                    Text("No projects")
                }
                Spacer()
            } else {
                VStack {
                    if self.preferences.hintDisabled == false {
                        HintView().environmentObject(self.preferences)
                    }
                    List {
                        ForEach(projects) { project in
                            ProjectCell(project: project).environmentObject(self.preferences)
                                .listRowInsets(EdgeInsets())
                        }
                        .onMove(perform: move)
//                        .padding(.top, 5)
                    }
                }
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        if searchTerm.isEmpty {
            preferences.moveProjects(from: source, to: destination)
        }
    }
}

extension MainView {
    private func addProject() {
        let appDelegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
        let dialog = NSOpenPanel()
        dialog.title = "Choose a folder with your project/workspace"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = true
        dialog.canChooseFiles = false
        dialog.becomesKeyOnlyIfNeeded = true

        appDelegate?.closePopover(sender: nil)

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let projectUrls = dialog.urls
            let projects = projectUrls.compactMap { Project(url: $0) }
            preferences.addProjects(projects)
            appDelegate?.showPopover(sender: nil)
        } else {
            print("something went wrong")
            appDelegate?.showPopover(sender: nil)
        }
    }
}
