// Online C compiler to run C program online
#include <stdio.h>

int main() {
    // Write C code here
    int target = 9;
    int nums[] = {2,34,7,10,10};
    int n = sizeof(nums)/sizeof(nums[0]); 
    for(int i =0;i<n;i++){
        int req_num = target - nums[i];
        for(int j=i+1;j<=n;j++){
            if(req_num==nums[j]){
                printf("Indicies: %d %d",i ,j);
            }
        }
    printf("\n");
    }
    printf("---------Code by Pavan");

    return 0;
}