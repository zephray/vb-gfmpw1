// Software CIC
// https://blog.y2kb.com/posts/pdm-mic-spi-cic/
#pragma once

struct CicFilter_t
{
    uint8_t order;
    uint32_t decimation;
    int32_t *out_i;
    int32_t *out_c;
    int32_t *z1_c;
};

void initializeCicFilterStruct(uint8_t, uint32_t, struct CicFilter_t*);
void resetCicFilterStruct(struct CicFilter_t*);
void executeCicFilter(uint8_t*, uint32_t, int32_t*, struct CicFilter_t*);
void finalizeCicFilterStruct(struct CicFilter_t*);
