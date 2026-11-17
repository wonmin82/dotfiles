#include <vector>
#include "local.h"
#include "llvm/ADT/StringRef.h"

#define TRACE_PAIR(a,b) do { Trace(a); Trace(b); } while(false)
namespace sample {



template<class First,class Second> class Pair {
public:
Pair(First first,Second second):long_first_member_name(first),long_second_member_name(second){}
int* find(int* input,int first_argument_with_a_long_name,int second_argument_with_a_long_name) {
if(first_argument_with_a_long_name>second_argument_with_a_long_name) { TRACE_PAIR(first_argument_with_a_long_name,second_argument_with_a_long_name); }
return input; // trailing comment
}
private:
First long_first_member_name;
Second long_second_member_name;
};
}
