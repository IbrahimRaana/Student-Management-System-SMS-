#!/bin/bash
# ================================
# Student Management System (SMS)
# ================================

# ======= File Definitions =======
DATA_FILE="students.txt"
TEACHER_CREDENTIALS="teacher_login.txt"
STUDENT_CREDENTIALS="student_login.txt"
CGPA_THRESHOLD=2.0

# ======= Initialize Files =======
[ ! -f "$DATA_FILE" ] && touch "$DATA_FILE"
[ ! -f "$TEACHER_CREDENTIALS" ] && touch "$TEACHER_CREDENTIALS"
[ ! -f "$STUDENT_CREDENTIALS" ] && touch "$STUDENT_CREDENTIALS"

# ======= Main Menu =======
main_menu() {
    while true; do
        echo "===== Student Management System ====="
        echo "1. Teacher Login"
        echo "2. Student Login"
        echo "3. Exit"
        read -p "Enter your choice: " choice

        case $choice in
            1) authenticate_teacher ;;
            2) authenticate_student ;;
            3) exit 0 ;;
            *) echo "Invalid choice. Try again." ;;
        esac
    done
}

# ======= Teacher Login =======
authenticate_teacher() {
    read -p "Enter Teacher Username: " username
    read -s -p "Enter Password: " password
    echo

    if grep -qx "$username:$password" "$TEACHER_CREDENTIALS"; then
        echo "Login Successful!"
        teacher_menu
    else
        echo "Invalid credentials."
    fi
}

# ======= Student Login =======
authenticate_student() {
    read -p "Enter Roll Number: " roll
    read -p "Enter Name: " name

    if grep -qx "$roll:$name" "$STUDENT_CREDENTIALS"; then
        echo "Login Successful!"
        student_menu "$roll"
    else
        echo "Invalid student credentials."
    fi
}

# ======= Add Student =======
add_student() {
    read -p "Enter Roll Number: " roll
    read -p "Enter Name: " name
    read -p "Enter Total Marks (0-100): " marks

    cgpa=$(echo "scale=2; $marks / 25" | bc)
    grade="F"

    if [ "$marks" -ge 90 ]; then grade="A+"; cgpa=4.0
    elif [ "$marks" -ge 80 ]; then grade="A"; cgpa=3.7
    elif [ "$marks" -ge 75 ]; then grade="B+"; cgpa=3.3
    elif [ "$marks" -ge 70 ]; then grade="B"; cgpa=3.0
    elif [ "$marks" -ge 65 ]; then grade="C+"; cgpa=2.5
    elif [ "$marks" -ge 60 ]; then grade="C"; cgpa=2.0
    elif [ "$marks" -ge 55 ]; then grade="C-"; cgpa=1.7
    elif [ "$marks" -ge 50 ]; then grade="D+"; cgpa=1.33
    elif [ "$marks" -ge 45 ]; then grade="D"; cgpa=1.0
    fi

    echo "$roll,$name,$marks,$cgpa,$grade" >> "$DATA_FILE"
    echo "$roll:$name" >> "$STUDENT_CREDENTIALS"
    echo "Student added successfully!"
}

# ======= View Student=======
view_student() {
    read -p "Enter Roll Number: " roll
    display_student "$roll"
}

display_student() {
    student=$(grep "^$1," "$DATA_FILE")
    if [ -z "$student" ]; then
        echo "Student not found."
        return
    fi

    echo "--------------------------------------------"
    echo "| Roll No | Name        | Marks | CGPA | Grade |"
    echo "--------------------------------------------"
    echo "$student" | awk -F',' '{ printf "| %-7s | %-10s | %-5s | %-4s | %-5s |\n", $1, $2, $3, $4, $5 }'
    echo "--------------------------------------------"
}

# ======= Delete Student =======
delete_student() {
    read -p "Enter Roll Number to delete: " roll
    grep -v "^$roll," "$DATA_FILE" > temp.txt && mv temp.txt "$DATA_FILE"
    grep -v "^$roll:" "$STUDENT_CREDENTIALS" > temp.txt && mv temp.txt "$STUDENT_CREDENTIALS"
    echo "Student deleted."
}

# ======= Assign or Update Marks =======
assign_marks() {
    read -p "Enter Roll Number: " roll
    read -p "Enter New Marks: " marks

    cgpa=$(echo "scale=2; $marks / 25" | bc)
    grade="F"
   
    if [ "$marks" -ge 90 ]; then grade="A+"; cgpa=4.0
    elif [ "$marks" -ge 80 ]; then grade="A"; cgpa=3.7
    elif [ "$marks" -ge 75 ]; then grade="B+"; cgpa=3.3
    elif [ "$marks" -ge 70 ]; then grade="B"; cgpa=3.0
    elif [ "$marks" -ge 65 ]; then grade="C+"; cgpa=2.5
    elif [ "$marks" -ge 60 ]; then grade="C"; cgpa=2.0
    elif [ "$marks" -ge 55 ]; then grade="C-"; cgpa=1.7
    elif [ "$marks" -ge 50 ]; then grade="D+"; cgpa=1.33
    elif [ "$marks" -ge 45 ]; then grade="D"; cgpa=1.0
    fi

    awk -F',' -v r="$roll" -v m="$marks" -v c="$cgpa" -v g="$grade" 'BEGIN{OFS=","}
        $1==r{$3=m; $4=c; $5=g} {print}' "$DATA_FILE" > temp.txt && mv temp.txt "$DATA_FILE"
    echo "Marks updated successfully."
}

# ======= Calculating grades =======
calculate_grades() {
    awk -F',' 'BEGIN{OFS=","}
    {
        grade = "F"
        if ($3 >= 90) {grade="A+"; cgpa=4.0}
        else if ($3 >= 80) {grade="A"; cgpa=3.7}
        else if ($3 >= 75) {grade="B+"; cgpa=3.3}
        else if ($3 >= 70) {grade="B"; cgpa=3.0}
        else if ($3 >= 65) {grade="C+"; cgpa=2.5}
        else if ($3 >= 60) {grade="C"; cgpa=2.0}
        else if ($3 >= 55) {grade="C-"; cgpa=1.7}
        else if ($3 >= 50) {grade="D+"; cgpa=1.33}
        else if ($3 >= 45) {grade="D"; cgpa=1.0}
        $4 = sprintf("%.2f", $cgpa)
        print $1, $2, $3, $4, grade
    }' "$DATA_FILE" > temp.txt && mv temp.txt "$DATA_FILE"
    echo "Grades recalculated for all students."
}

# ======= Sort Students by CGPA =======
sort_students() {
    echo "1. Ascending Order"
    echo "2. Descending Order"
    read -p "Choose: " order

    if [ "$order" -eq 1 ]; then
        sort -t',' -k4,4n "$DATA_FILE"
    else
        sort -t',' -k4,4nr "$DATA_FILE"
    fi
}

# ======= List of Passed  or Failed =======
list_pass_fail() {
    echo "1. Passed Students"
    echo "2. Failed Students"
    read -p "Choose: " choice

    if [ "$choice" -eq 1 ]; then
        awk -F',' -v th="$CGPA_THRESHOLD" '$4 >= th' "$DATA_FILE"
    else
        awk -F',' -v th="$CGPA_THRESHOLD" '$4 < th' "$DATA_FILE"
    fi
}

# ======= Teacher Menu =======
teacher_menu() {
    while true; do
        echo "===== Teacher Menu ====="
        echo "1. Add Student"
        echo "2. View Student"
        echo "3. Delete Student"
        echo "4. Assign Marks"
        echo "5. Calculate Grades"
        echo "6. Sort Students"
        echo "7. List Passed/Failed"
        echo "8. Logout"
        read -p "Enter your choice: " choice

        case $choice in
            1) add_student ;;
            2) view_student ;;
            3) delete_student ;;
            4) assign_marks ;;
            5) calculate_grades ;;
            6) sort_students ;;
            7) list_pass_fail ;;
            8) break ;;
            *) echo "Invalid choice!" ;;
        esac
    done
}

# ======= Student Menu =======
student_menu() {
    roll="$1"
    while true; do
        echo "===== Student Menu ====="
        echo "1. View Grades"
        echo "2. View CGPA"
        echo "3. Logout"
        read -p "Choose: " choice

        case $choice in
            1) display_student "$roll" ;;
            2) awk -F',' -v r="$roll" '$1 == r { print "CGPA: " $4 }' "$DATA_FILE" ;;
            3) break ;;
            *) echo "Invalid choice!" ;;
        esac
    done
}

# ======= Start Program =======
main_menu
