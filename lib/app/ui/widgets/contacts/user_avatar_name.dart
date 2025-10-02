import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatarName extends StatelessWidget {
  final String? avatar;
  final String? name;
  final VoidCallback? onTap;
  final double avatarSize;
  final double borderRadius;

  const UserAvatarName({
    Key? key,
    this.avatar,
    this.name,
    this.onTap,
    this.avatarSize = 40,
    this.borderRadius = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.grey[200],
        ),
        clipBehavior: Clip.hardEdge,
        child: avatar != null
            ? CachedNetworkImage(
                imageUrl: avatar!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              )
            : const Icon(Icons.person),
      ),
      title: Text(name ?? ''),
      onTap: onTap,
    );
  }
}
