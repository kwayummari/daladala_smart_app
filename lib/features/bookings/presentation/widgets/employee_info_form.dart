
import 'package:flutter/material.dart';

class EmployeeInfoForm extends StatelessWidget {
  final TextEditingController employeeNameController;
  final TextEditingController employeeIdController;
  final TextEditingController departmentController;

  const EmployeeInfoForm({
    Key? key,
    required this.employeeNameController,
    required this.employeeIdController,
    required this.departmentController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Employee Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Employee Name
            TextFormField(
              controller: employeeNameController,
              decoration: const InputDecoration(
                labelText: 'Employee Name *',
                hintText: 'Enter employee full name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Employee name is required';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Employee ID
            TextFormField(
              controller: employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                hintText: 'Enter employee ID (optional)',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 3) {
                  return 'Employee ID must be at least 3 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Department
            TextFormField(
              controller: departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                hintText: 'Enter department name (optional)',
                prefixIcon: Icon(Icons.business_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Employee information will be used for booking records and reporting purposes.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}