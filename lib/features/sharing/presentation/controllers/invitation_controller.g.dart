// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharingRepositoryHash() => r'489ece8e0094f3ddf0a64d941fde8204a1b6dfb5';

/// See also [sharingRepository].
@ProviderFor(sharingRepository)
final sharingRepositoryProvider =
    AutoDisposeProvider<SharingRepository>.internal(
      sharingRepository,
      name: r'sharingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharingRepositoryRef = AutoDisposeProviderRef<SharingRepository>;
String _$invitationControllerHash() =>
    r'b2dfbc574c00e3f8666358f20ba9b873a7b1355f';

/// See also [InvitationController].
@ProviderFor(InvitationController)
final invitationControllerProvider =
    AutoDisposeStreamNotifierProvider<
      InvitationController,
      List<InvitationModel>
    >.internal(
      InvitationController.new,
      name: r'invitationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$invitationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InvitationController =
    AutoDisposeStreamNotifier<List<InvitationModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
