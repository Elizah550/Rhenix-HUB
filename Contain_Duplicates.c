#include <stdio.h>
#include <stdbool.h>

bool containsDuplicate(int* nums, int numsSize) {
    for (int i = 0; i < numsSize; i++) {
        for (int j = i + 1; j < numsSize; j++) {
            if (nums[i] == nums[j]) {
                return true; // Duplicate found
            }
        }
    }
    return false; // No duplicates found
}

int main() {
    int nums[] = {1, 2, 3, 1}; // Example input
    int numsSize = sizeof(nums) / sizeof(nums[0]);

    if (containsDuplicate(nums, numsSize)) {
        printf("Duplicates are present.\n");
    } else {
        printf("No duplicates found.\n");
    }

    return 0;
}
