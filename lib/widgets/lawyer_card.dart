import 'package:flutter/material.dart';

class LawyerCard extends StatelessWidget {
  final String name;
  final double rating;
  final int totalCases;
  final int casesWon;
  final int activeCases;
  final String specialization;
  final String? profileImageUrl; // ✅ ADDED: To display the lawyer's photo
  final VoidCallback onTap;

  const LawyerCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.totalCases,
    required this.casesWon,
    required this.activeCases,
    required this.specialization,
    this.profileImageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Remove default shadow
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white24, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person,
                            size: 30, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialization,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                ],
              ),
              const Divider(color: Colors.white30, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.star_border_rounded,
                    label: "Rating",
                    value: rating.toStringAsFixed(1),
                    color: Colors.amber.shade400,
                  ),
                  _StatItem(
                    icon: Icons.work_outline_rounded,
                    label: "Total",
                    value: totalCases.toString(),
                  ),
                   _StatItem(
                    icon: Icons.check_circle_outline_rounded,
                    label: "Won",
                    value: casesWon.toString(),
                  ),
                  _StatItem(
                    icon: Icons.hourglass_top_rounded,
                    label: "Active",
                    value: activeCases.toString(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// A private helper widget for displaying individual stats cleanly
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color ?? Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
