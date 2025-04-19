# Student Management System (SMS)

A terminal-based Student Management System implemented using Bash scripting. This project is aimed at showcasing how powerful shell scripting can be when it comes to building interactive, file-based applications. It is particularly suitable for educational environments where simplicity, transparency, and accessibility are key.

 🔧 Features

- **Teacher Login System**: Secure credential-based login for authorized teachers.
- **Student Login System**: Allows students to log in and view their individual academic information.
- **Add Student**: Facilitates entry of new student records with proper validation for roll number and name.
- **View Student**: Quickly fetch and display student details by roll number.
- **Delete Student**: Permanently remove a student’s data from the records.
- **Assign/Update Marks**: Modify or input marks for a student and automatically update academic records.
- **Calculate Records**: Batch update all student records to ensure consistency after bulk changes.
- **Sort Students**: Sorts student data based on CGPA in ascending or descending order for better insights.
- **Pass/Fail Lists**: Generate lists of passed or failed students based on a defined CGPA threshold.

 📁 File Structure

- `students.txt` – Contains the main dataset with student details (roll number, name, marks, CGPA, grade).
- `teacher_login.txt` – Stores teacher credentials in `username:password` format.
- `student_login.txt` – Maintains student login entries in `roll:name` format.

 🛠 Requirements

- Any Unix-like OS with Bash support (Linux/macOS/WSL).
- Basic terminal and shell scripting knowledge.

 📚 Use Case

This project was developed as part of an academic requirement for an Operating Systems course. It reflects a practical use of scripting to simulate real-world system interactions like login authentication, file-based data manipulation, and menu-driven user experiences.



