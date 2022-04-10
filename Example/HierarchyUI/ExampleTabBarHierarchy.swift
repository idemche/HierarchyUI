//
//  ExampleTabBarHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 09.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import HierarchyUI

struct ExampleTabBarHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        TabBarHierarchy(key: "MainTabBar", initialTabIndex: 1)
            .tab(tabBarSystemItem: .bookmarks) {
                View1().route(key: "1").pushes {
                    View5().route(key: "5").pushes {
                        View6().route(key: "6").pushes {
                            View7().route(key: "8").pushes {
                                View8().route(key: "9")
                            }
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .contacts) {
                View2().route(key: "2").pushes {
                    View5().route(key: "5").pushes {
                        View6().route(key: "6").pushes {
                            View7().route(key: "8").pushes {
                                View8().route(key: "9")
                            }
                        }
                    }
                }.modals {
                    View12().route(key: "12").pushes {
                        View13().route(key: "13").pushes {
                            View14().route(key: "14")
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .downloads) {
                View3().route(key: "3").pushes {
                    View5().route(key: "5").pushes {
                        View6().route(key: "6").pushes {
                            View7().route(key: "8").pushes {
                                View8().route(key: "9")
                            }
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .favorites) {
                View4().route(key: "4").pushes {
                    View5().route(key: "5").pushes {
                        View6().route(key: "6").pushes {
                            View7().route(key: "8").pushes {
                                View8().route(key: "9")
                            }
                        }
                    }
                }
            }
            .build()
    }
}
