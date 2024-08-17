import Foundation

protocol OnboardingCoordinatorFactory: IntroFactory { }

protocol MainCoordinatorFactory: HomeFactory,
                                 MyProfileFactory,
                                 DetailsFactory,
                                 SearchFactory { }

