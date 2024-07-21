#include <stdio.h>
#include <stdbool.h>

int* productExceptSelf(int* nums, int numsSize, int* returnSize) {
    int* left = (int*)malloc(numsSize * sizeof(int));
    int* right = (int*)malloc(numsSize * sizeof(int));
    int* ans = (int*)malloc(numsSize * sizeof(int));
    int n = numsSize;
    *returnSize = numsSize;

    //left array
    left[0] = 1;
    for (int i = 1; i < n; i++) {
        left[i] = left[i - 1] * nums[i - 1];
    }

    //right array
    right[n - 1] = 1;
    for (int i = n - 2; i >= 0; i--) {
        right[i] = right[i + 1] * nums[i + 1];
    }

    //ans array
    for (int i = 0; i < n; i++) {
        ans[i] = left[i] * right[i];
    }

    // Free the left and right arrays
    free(left);
    free(right);

    // Return the ans array
    return ans;
}