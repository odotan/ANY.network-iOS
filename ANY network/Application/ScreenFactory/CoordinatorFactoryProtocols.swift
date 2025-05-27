import Foundation

protocol OnboardingCoordinatorFactory: IntroFactory { }

protocol MainCoordinatorFactory: HomeFactory,
                                 MyProfileFactory,
                                 DetailsFactory,
                                 SearchFactory,
                                 ConnectFactory,
                                 ConnectNetworkConfirmationFactory,
                                 ConnectNetworkSignUpFactory,
                                 RequestNetworkFactory,
                                 HiUFactory { }

