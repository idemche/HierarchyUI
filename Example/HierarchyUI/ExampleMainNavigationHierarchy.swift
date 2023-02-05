//
//  ExampleMainNavigationHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import HierarchyUI

struct ExampleMainNavigationHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        View1().route(key: "1").pushes {
            View2().route(key: "2").pushes {
                View3().route(key: "3").pushes {
                    View4().route(key: "4").pushes {
                        [
                            View5().route(key: "5"),
                            View6().route(key: "6").pushes {
                                View8().route(key: "8").pushes {
                                    View9().route(key: "9").pushes {
                                        View10().route(key: "10").pushes {
                                            View11().route(key: "11").pushes {
                                                ExampleTabBarHierarchy().structure()
                                            }.replaces {
                                                ExampleTabBarHierarchy().structure()
                                            }
                                        }
                                    }
                                }
                            },
                            View7().route(key: "7"),
                        ]
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
    }
}
