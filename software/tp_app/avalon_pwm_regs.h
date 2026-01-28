#ifndef AVALON_PWM_REGS_H
#define AVALON_PWM_REGS_H
#include <io.h>
#include <stdint.h>
#define PWM_REG_DUTY_OFST 0
#define PWM_REG_PERIOD_OFST 1
static inline void pwm_write_duty(uint32_t base, uint32_t duty)
{
IOWR(base, PWM_REG_DUTY_OFST, duty);
}
static inline void pwm_write_period(uint32_t base, uint32_t period)
{
IOWR(base, PWM_REG_PERIOD_OFST, period);
}
static inline uint32_t pwm_read_duty(uint32_t base)
{
return IORD(base, PWM_REG_DUTY_OFST);
}
static inline uint32_t pwm_read_period(uint32_t base)
{
return IORD(base, PWM_REG_PERIOD_OFST);
}
#endif
