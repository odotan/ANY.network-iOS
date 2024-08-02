import Foundation

protocol OnboardingCoordinatorFactory: IntroFactory,
                                       ConnectFactory,
                                       ContactsPermissionFactory { }

protocol MainCoordinatorFactory: HomeFactory,
                                 MyProfileFactory,
                                 DetailsFactory,
                                 SearchFactory { }

